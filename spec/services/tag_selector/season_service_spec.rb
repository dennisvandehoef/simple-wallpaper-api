require "rails_helper"

RSpec.describe TagSelector::SeasonService, type: :service do
  # Create the season tag group and associated system tags used by the service
  let!(:season_group) { TagGroup.create!(name: "Season", system: true) }
  let!(:winter_tag)   { Tag.create!(name: "Winter", tag_group: season_group, system: true) }
  let!(:spring_tag)   { Tag.create!(name: "Spring", tag_group: season_group, system: true) }
  let!(:summer_tag)   { Tag.create!(name: "Summer", tag_group: season_group, system: true) }
  let!(:fall_tag)     { Tag.create!(name: "Fall",   tag_group: season_group, system: true) }

  describe ".tags" do
    {
      "2024-12-21" => "Winter", # winter start
      "2025-02-15" => "Winter", # mid-winter (previous year)
      "2025-03-20" => "Spring", # spring start
      "2025-06-21" => "Summer", # summer start
      "2025-09-22" => "Fall",   # fall start
      "2025-12-20" => "Fall"    # day before winter start
    }.each do |date_string, expected_name|
      it "returns the #{expected_name} tag for #{date_string}" do
        result = described_class.tags(Date.parse(date_string))
        expect(result.map(&:name)).to eq([ expected_name ])
      end
    end
  end
end
