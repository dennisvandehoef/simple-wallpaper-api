class SeedTemperatureTags < ActiveRecord::Migration[8.0]
  TAGS = [
    'Icy (≤ -5°C)',
    'Freezing (-4°C to 0°C)',
    'Cold (1°C to 5°C)',
    'Chilly (6°C to 10°C)',
    'Cool (11°C to 15°C)',
    'Mild (16°C to 20°C)',
    'Warm (21°C to 25°C)',
    'Hot (26°C to 30°C)',
    'Very Hot (> 30°C)'
  ].freeze

  def up
    group = TagGroup.find_or_create_by!(name: 'Temperature') { |g| g.system = true }
    TAGS.each do |name|
      group.tags.find_or_create_by!(name: name) { |t| t.system = true }
    end
  end

  def down
    TagGroup.find_by(name: 'Temperature')&.destroy!
  end
end
