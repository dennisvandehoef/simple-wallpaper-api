# frozen_string_literal: true

module TagSelector
  # Provides weather-condition system tag corresponding to a WMO code.
  # Usage:
  #   TagSelector::WeatherService.tag(63) # => <Tag name="Rain">
  #   TagSelector::WeatherService.tags(63) # => [<Tag ...>]
  # Returns empty array if the code is unknown or tag is missing.
  class WeatherService
    CODE_TO_NAME = {
      0  => "Clear",
      1  => "Mostly Clear",
      2  => "Partly Cloudy",
      3  => "Overcast",
      45 => "Fog",
      48 => "Icy Fog",
      51 => "Light Drizzle",
      53 => "Drizzle",
      55 => "Heavy Drizzle",
      80 => "Light Showers",
      81 => "Showers",
      82 => "Heavy Showers",
      61 => "Light Rain",
      63 => "Rain",
      65 => "Heavy Rain",
      56 => "Light Freezing Drizzle",
      57 => "Freezing Drizzle",
      66 => "Light Freezing Rain",
      67 => "Freezing Rain",
      77 => "Snow Grains",
      85 => "Light Snow Showers",
      86 => "Snow Showers",
      71 => "Light Snow",
      73 => "Snow",
      75 => "Heavy Snow",
      95 => "Thunderstorm",
      96 => "Light Thunderstorm with Hail",
      99 => "Thunderstorm with Hail"
    }.freeze

    class << self
      def tag(code)
        name = CODE_TO_NAME[code.to_i]
        return nil unless name

        Tag.find_by(name: name, system: true)
      end

      # Returns an array with the weather-condition tag for a given WMO code.
      # If the code is unknown or no matching system tag exists, returns an empty array.
      def tags(code)
        tag(code).presence ? [ tag(code) ] : []
      end

      # Fetches the current weather code from OpenMeteoService and returns
      # the corresponding system tag(s). Falls back to an empty array on
      # API errors or when no code/tag is available.
      def current_tags
        begin
          data = OpenMeteoService.fetch
          code = data.dig("daily", "weather_code", 0)
        rescue StandardError => e
          Rails.logger.error("WeatherService: #{e.message}")
          return []
        end

        return [] unless code

        tags(code)
      end
    end
  end
end
