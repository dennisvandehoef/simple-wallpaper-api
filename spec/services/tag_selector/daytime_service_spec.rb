require "rails_helper"

RSpec.describe TagSelector::DaytimeService, type: :service do
  let!(:group) { TagGroup.create!(name: "Daytime", system: true) }
  let!(:day_tag) { Tag.create!(name: "Day", tag_group: group, system: true) }
  let!(:night_tag) { Tag.create!(name: "Night", tag_group: group, system: true) }

  describe ".tags" do
    context "when OpenMeteoService returns is_day = 1" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({ "current" => { "is_day" => 1 } })
      end

      it "returns the Day tag" do
        expect(described_class.tags).to eq([ day_tag ])
      end
    end

    context "when OpenMeteoService returns is_day = 0" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({ "current" => { "is_day" => 0 } })
      end

      it "returns the Night tag" do
        expect(described_class.tags).to eq([ night_tag ])
      end
    end

    context "when OpenMeteoService returns unexpected value" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({ "current" => { "is_day" => 2 } })
      end

      it "returns an empty array" do
        expect(described_class.tags).to eq([])
      end
    end

    context "when OpenMeteoService raises an error" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_raise(StandardError, "boom")
      end

      it "logs the error and returns an empty array" do
        expect(Rails.logger).to receive(:error).with(/DaytimeService: boom/)
        expect(described_class.tags).to eq([])
      end
    end
  end
end
