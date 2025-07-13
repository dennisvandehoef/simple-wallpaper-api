module WeatherConditionsHelper
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

  # Returns the human-readable weather condition name for a given WMO code.
  # Accepts Integer or String; returns nil if unknown.
  def weather_condition_name(code)
    CODE_TO_NAME[code.to_i]
  end
end
