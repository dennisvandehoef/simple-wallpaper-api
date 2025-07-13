class SeedWeatherConditionTags < ActiveRecord::Migration[7.1]
  TAGS = [
    "Clear",
    "Mostly Clear",
    "Partly Cloudy",
    "Overcast",
    "Fog",
    "Icy Fog",
    "Light Drizzle",
    "Drizzle",
    "Heavy Drizzle",
    "Light Showers",
    "Showers",
    "Heavy Showers",
    "Light Rain",
    "Rain",
    "Heavy Rain",
    "Light Freezing Drizzle",
    "Freezing Drizzle",
    "Light Freezing Rain",
    "Freezing Rain",
    "Snow Grains",
    "Light Snow Showers",
    "Snow Showers",
    "Light Snow",
    "Snow",
    "Heavy Snow",
    "Thunderstorm",
    "Light Thunderstorm with Hail",
    "Thunderstorm with Hail"
  ].freeze

  def up
    group = TagGroup.find_or_create_by!(name: "Weather Conditions") { |g| g.system = true }

    TAGS.each do |name|
      group.tags.find_or_create_by!(name: name) { |t| t.system = true }
    end
  end

  def down
    group = TagGroup.find_by(name: "Weather Conditions")
    group&.destroy!
  end
end
