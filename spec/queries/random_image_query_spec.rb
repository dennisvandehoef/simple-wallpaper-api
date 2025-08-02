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
    @img_seq ||= 0
    @img_seq += 1
    instance_double(Image, id: @img_seq, tags: tags)
  end

  context "eligibility rules" do
    it "is eligible with exact match (1 tag per group)" do
      candidate = img("Exact", [ summer_tag, day_tag, xmas_tag, mild_tag, rain_tag ])
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))
      expect(described_class.call).to eq(candidate)
    end

    it "is eligible with multiple temp/weather tags as long as one matches" do
      candidate = img("MultiOverlap", [ summer_tag, day_tag, xmas_tag, mild_tag, icy_tag, hot_tag, rain_tag, snow_tag ])
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))
      expect(described_class.call).to eq(candidate)
    end

    it "is ineligible when season mismatched" do
      candidate = img("SeasonMismatch", [ winter_tag, day_tag, xmas_tag, mild_tag, rain_tag ])
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))
      expect(described_class.call).to be_nil
    end

    it "is eligible when holiday group missing" do
      candidate = img("NoHoliday", [ summer_tag, day_tag, mild_tag, rain_tag ])
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))
      expect(described_class.call).to eq(candidate)
    end

    it "is ineligible when multiple season tags but none match" do
      candidate = img("MultiSeasonNoMatch", [ winter_tag, night_tag, xmas_tag, mild_tag, rain_tag ])
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))
      expect(described_class.call).to be_nil
    end

    it "is ineligible when multiple weather tags but none match" do
      candidate = img("WeatherNoMatch", [ summer_tag, day_tag, xmas_tag, mild_tag, clear_tag, snow_tag ])
      allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ candidate ]))
      expect(described_class.call).to be_nil
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

  it "does not return the same image twice in a row when multiple eligible images exist" do
    img1 = img("Img1", [ summer_tag, day_tag, xmas_tag, mild_tag, rain_tag ])
    img2 = img("Img2", [ summer_tag, day_tag, xmas_tag, mild_tag, rain_tag ])

    allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ img1, img2 ]))
    Rails.cache.clear

    first = described_class.call
    expect([ img1, img2 ]).to include(first)

    # Next call with reversed order to ensure alternative available
    allow(Image).to receive_message_chain(:joins, :includes).and_return(double(order: [ img2, img1 ]))
    second = described_class.call
    expect(second).not_to eq(first)
  end
end
