module ApplicationHelper
  # Returns an image tag for the given weather-condition tag if a matching
  # icon is present in app/assets/images/icons.
  #
  # Filenames are expected to follow the pattern:
  #   icons/<slug>@4x.png
  #
  WEATHER_ICON_SLUGS = {
    "Clear" => "clear",
    "Mostly Clear" => "mostly-clear",
    "Partly Cloudy" => "partly-cloudy",
    "Overcast" => "overcast",
    "Fog" => "fog",
    "Icy Fog" => "rime-fog",
    "Light Drizzle" => "light-drizzle",
    "Drizzle" => "moderate-drizzle",
    "Heavy Drizzle" => "dense-drizzle",
    "Light Showers" => "light-rain",
    "Showers" => "moderate-rain",
    "Heavy Showers" => "heavy-rain",
    "Light Rain" => "light-rain",
    "Rain" => "moderate-rain",
    "Heavy Rain" => "heavy-rain",
    "Light Freezing Drizzle" => "light-freezing-drizzle",
    "Freezing Drizzle" => "dense-freezing-drizzle",
    "Light Freezing Rain" => "light-freezing-rain", # icon may alias heavy-freezing-rain if missing
    "Freezing Rain" => "heavy-freezing-rain",
    "Snow Grains" => "snowflake",
    "Light Snow Showers" => "slight-snowfall",
    "Snow Showers" => "heavy-snowfall",
    "Light Snow" => "slight-snowfall",
    "Snow" => "moderate-snowfall",
    "Heavy Snow" => "heavy-snowfall",
    "Thunderstorm" => "thunderstorm",
    "Light Thunderstorm with Hail" => "thunderstorm-with-hail",
    "Thunderstorm with Hail" => "thunderstorm-with-hail"
  }.freeze

  def weather_icon_for(tag, size: 48)
    return unless tag.tag_group&.name == "Weather Conditions"

    slug = WEATHER_ICON_SLUGS[tag.name] || tag.name.parameterize
    filename = "icons/#{slug}@4x.png"

    # Build the image tag, but silently ignore when the asset is missing –
    # Propshaft raises `Propshaft::MissingAssetError` in that case.
    image_tag(filename, alt: tag.name, height: size, width: size)
  rescue StandardError
    nil
  end
end
