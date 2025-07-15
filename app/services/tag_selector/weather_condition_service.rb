# frozen_string_literal: true

module TagSelector
  # Determines current weather condition tag(s) using OpenMeteoService.
  class WeatherConditionService
    class << self
      def tags
        begin
          data = OpenMeteoService.fetch
          code = data.dig("daily", "weather_code", 0)
        rescue StandardError => e
          Rails.logger.error("WeatherConditionService: #{e.message}")
          return []
        end

        return [] unless code

        WeatherService.tags(code)
      end
    end
  end
end
