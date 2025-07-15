# frozen_string_literal: true

module TagSelector
  # Selects a temperature tag based on current max temperature in °C.
  class TemperatureService
    MAPPINGS = [
      { range: ->(t) { t <= -5 },  name: "Icy (≤ -5°C)" },
      { range: ->(t) { (-4..0).include?(t) }, name: "Freezing (-4°C to 0°C)" },
      { range: ->(t) { (1..5).include?(t) },  name: "Cold (1°C to 5°C)" },
      { range: ->(t) { (6..10).include?(t) }, name: "Chilly (6°C to 10°C)" },
      { range: ->(t) { (11..15).include?(t) }, name: "Cool (11°C to 15°C)" },
      { range: ->(t) { (16..20).include?(t) }, name: "Mild (16°C to 20°C)" },
      { range: ->(t) { (21..25).include?(t) }, name: "Warm (21°C to 25°C)" },
      { range: ->(t) { (26..30).include?(t) }, name: "Hot (26°C to 30°C)" },
      { range: ->(t) { t > 30 }, name: "Very Hot (> 30°C)" }
    ].freeze

    class << self
      def tags
        begin
          data = OpenMeteoService.fetch
          is_day = data.dig("current", "is_day").to_i
          temp_key = is_day == 0 ? "temperature_2m_min" : "temperature_2m_max"
          temp = data.dig("daily", temp_key, 0)
        rescue StandardError => e
          Rails.logger.error("TemperatureService: #{e.message}")
          return []
        end

        return [] unless temp

        mapping = MAPPINGS.find { |m| m[:range].call(temp.to_f) }
        return [] unless mapping

        tag = Tag.find_by(name: mapping[:name], system: true)
        tag ? [ tag ] : []
      end
    end
  end
end
