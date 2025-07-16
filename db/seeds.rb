# frozen_string_literal: true

# Seed helper to ensure idempotent creation of tag groups and tags

def seed_group_with_tags(group_name, tags)
  group = TagGroup.find_or_create_by!(name: group_name) { |g| g.system = true }
  tags.each do |name|
    group.tags.find_or_create_by!(name: name) { |t| t.system = true }
  end
end

# Weather Conditions
seed_group_with_tags("Weather Conditions", [
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
])

# Seasons
seed_group_with_tags("Seasons", %w[Spring Summer Fall Winter])

# Holidays
seed_group_with_tags("Holidays", [
  "Christmas",
  "New Year's Eve",
  "Easter",
  "Valentine's Day"
])

# Daytime
seed_group_with_tags("Daytime", %w[Day Night])

# Temperature
seed_group_with_tags("Temperature", [
  "Icy (≤ -5°C)",
  "Freezing (-4°C to 0°C)",
  "Cold (1°C to 5°C)",
  "Chilly (6°C to 10°C)",
  "Cool (11°C to 15°C)",
  "Mild (16°C to 20°C)",
  "Warm (21°C to 25°C)",
  "Hot (26°C to 30°C)",
  "Very Hot (> 30°C)"
])

puts "Updated system tag groups and tags."
