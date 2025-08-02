require "rails_helper"

RSpec.describe RandomImageQuery do
  # ---------------------------------------------------------------------------
  # Setup Groups and System Tags (representative subset)
  # ---------------------------------------------------------------------------
  let!(:season_group)      { TagGroup.create!(name: "Seasons", system: true) }
  let!(:daytime_group)     { TagGroup.create!(name: "Daytime", system: true) }
  let!(:holiday_group)     { TagGroup.create!(name: "Holidays", system: true) }
  let!(:temperature_group) { TagGroup.create!(name: "Temperature", system: true) }
  let!(:weather_group)     { TagGroup.create!(name: "Weather Conditions", system: true) }

  # Seasons
  let!(:summer_tag) { Tag.create!(name: "Summer", tag_group: season_group, system: true) }
  let!(:winter_tag) { Tag.create!(name: "Winter", tag_group: season_group, system: true) }

  # Daytime
  let!(:day_tag)   { Tag.create!(name: "Day",   tag_group: daytime_group, system: true) }
  let!(:night_tag) { Tag.create!(name: "Night", tag_group: daytime_group, system: true) }

  # Holiday
  let!(:xmas_tag) { Tag.create!(name: "Christmas", tag_group: holiday_group, system: true) }

  # Temperature (choose 3 representatives)
  let!(:icy_tag)  { Tag.create!(name: "Icy (≤ -5°C)",           tag_group: temperature_group, system: true) }
  let!(:mild_tag) { Tag.create!(name: "Mild (16°C to 20°C)",    tag_group: temperature_group, system: true) }
  let!(:hot_tag)  { Tag.create!(name: "Hot (26°C to 30°C)",     tag_group: temperature_group, system: true) }

  # Weather (choose 3 representatives)
  let!(:clear_tag) { Tag.create!(name: "Clear", tag_group: weather_group, system: true) }
  let!(:rain_tag)  { Tag.create!(name: "Rain",  tag_group: weather_group, system: true) }
  let!(:snow_tag)  { Tag.create!(name: "Snow",  tag_group: weather_group, system: true) }

  # ---------------------------------------------------------------------------
  # Stub selector services – fixed active tags for all examples
  # ---------------------------------------------------------------------------
  before do
    allow(TagSelector::SeasonService).to        receive(:tags).and_return([ summer_tag ])
    allow(TagSelector::DaytimeService).to       receive(:tags).and_return([ day_tag ])
    allow(TagSelector::HolidayService).to       receive(:tags).and_return([ xmas_tag ])
    allow(TagSelector::TemperatureService).to   receive(:tags).and_return([ mild_tag ])
    allow(TagSelector::WeatherService).to       receive(:tags).and_return([ rain_tag ])
  end

  # Helper to build an Image double with given tags
  def img(name, tags)
    double(name, tags: tags)
  end

  # ---------------------------------------------------------------------------
  # Scenarios matrix – each entry is [description, tags, expected]
  #   – expected: true means image should be chosen when first in order list
  # ---------------------------------------------------------------------------
  scenarios = [
    [
      "exact match, one tag per group",
      -> { [ summer_tag, day_tag, xmas_tag, mild_tag, rain_tag ] },
      true
    ],
    [
      "multiple tags in temperature & weather – at least one overlaps",
      -> { [ summer_tag, day_tag, xmas_tag, mild_tag, icy_tag, hot_tag, rain_tag, snow_tag ] },
      true
    ],
    [
      "season mismatch (has Winter instead of Summer)",
      -> { [ winter_tag, day_tag, xmas_tag, mild_tag, rain_tag ] },
      false
    ],
    [
      "no holiday tag (group missing) should still qualify",
      -> { [ summer_tag, day_tag, mild_tag, rain_tag ] },
      true
    ],
    [
      "multi-tags in season none overlapping (Winter + another)",
      -> { [ winter_tag, night_tag, xmas_tag, mild_tag, rain_tag ] },
      false
    ],
    [
      "multi tags in weather but none overlapping (Clear + Snow)",
      -> { [ summer_tag, day_tag, xmas_tag, mild_tag, clear_tag, snow_tag ] },
      false
    ]
  ]

  # ---------------------------------------------------------------------------
  #   Dynamically create examples based on scenarios matrix
  # ---------------------------------------------------------------------------
  scenarios.each do |desc, tag_list, should_match|
    it "#{desc} ⇒ #{should_match ? "eligible" : "ineligible"}" do
      candidate = img(desc, instance_exec(&tag_list))
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))

      result = described_class.call
      if should_match
        expect(result).to eq(candidate)
      else
        expect(result).to be_nil
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Ensure eligibility respects order – first eligible selected
  # ---------------------------------------------------------------------------
  it "selects the first eligible image in randomized order" do
    eligible   = img("Eligible", [ summer_tag, day_tag, xmas_tag, mild_tag, rain_tag ])
    ineligible = img("Ineligible", [ winter_tag, day_tag, xmas_tag, mild_tag, rain_tag ])

    allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ ineligible, eligible ]))

    expect(described_class.call).to eq(eligible)
  end
end
