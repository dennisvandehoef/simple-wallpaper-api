# frozen_string_literal: true

module TagSelector
  # Selects "Day" or "Night" system tag based on Open-Meteo `is_day` current value.
  class DaytimeService
    class << self
      def tags
        begin
          data = OpenMeteoService.fetch
          is_day = data.dig("current", "is_day")
        rescue StandardError => e
          Rails.logger.error("DaytimeService: #{e.message}")
          is_day = nil
        end

        return [] unless [ 0, 1, "0", "1" ].include?(is_day)

        tag_name = is_day.to_i == 1 ? "Day" : "Night"
        tag = Tag.find_by(name: tag_name, system: true)
        tag ? [ tag ] : []
      end
    end
  end
end
