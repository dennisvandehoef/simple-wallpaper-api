require "rails_helper"

RSpec.describe TagSelector::TemperatureService, type: :service do
  let!(:group) { TagGroup.create!(name: "Temperature", system: true) }
  let!(:mild_tag) { Tag.create!(name: "Mild (16°C to 20°C)", tag_group: group, system: true) }
  let!(:icy_tag)  { Tag.create!(name: "Icy (≤ -5°C)",          tag_group: group, system: true) }

  describe ".tags" do
    context "daytime - uses max temperature" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({
          "current" => { "is_day" => 1 },
          "daily"   => { "temperature_2m_max" => [ 18 ] }
        })
      end

      it "returns Mild tag for 18°C max" do
        expect(described_class.tags).to eq([ mild_tag ])
      end
    end

    context "nighttime - uses min temperature" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({
          "current" => { "is_day" => 0 },
          "daily"   => { "temperature_2m_min" => [ -6 ] }
        })
      end

      it "returns Icy tag for -6°C min" do
        expect(described_class.tags).to eq([ icy_tag ])
      end
    end

    context "when temperature value is missing" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_return({
          "current" => { "is_day" => 1 },
          "daily"   => {}
        })
      end

      it "returns empty array" do
        expect(described_class.tags).to eq([])
      end
    end

    context "when OpenMeteoService raises error" do
      before do
        allow(OpenMeteoService).to receive(:fetch).and_raise(StandardError, "temp fail")
      end

      it "logs error and returns empty array" do
        expect(Rails.logger).to receive(:error).with(/TemperatureService: temp fail/)
        expect(described_class.tags).to eq([])
      end
    end
  end
end
