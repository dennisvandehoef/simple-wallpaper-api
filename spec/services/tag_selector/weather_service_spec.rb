require "rails_helper"

RSpec.describe TagSelector::WeatherService, type: :service do
  let!(:group) { TagGroup.create!(name: "Weather Conditions", system: true) }
  let!(:rain_tag) { Tag.create!(name: "Rain", tag_group: group, system: true) }


  describe ".tags" do
    it "wraps the tag in an array when present" do
      expect(described_class.tags(63)).to eq([ rain_tag ])
    end

    it "returns empty array for unknown code" do
      expect(described_class.tags(999)).to eq([])
    end
  end

  describe ".tags (no argument)" do
    context "when OpenMeteoService returns a valid code" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({ "daily" => { "weather_code" => [ 63 ] } })
      end

      it "returns the mapped tag" do
        expect(described_class.tags).to eq([ rain_tag ])
      end
    end

    context "when OpenMeteoService returns nil code" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({ "daily" => { "weather_code" => [ nil ] } })
      end

      it "returns empty array" do
        expect(described_class.tags).to eq([])
      end
    end

    context "when OpenMeteoService raises an error" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_raise(StandardError, "api boom")
      end

      it "logs the error and returns empty array" do
        expect(Rails.logger).to receive(:error).with(/WeatherService: api boom/)
        expect(described_class.tags).to eq([])
      end
    end
  end
end
