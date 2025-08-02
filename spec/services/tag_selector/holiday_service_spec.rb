require "rails_helper"

RSpec.describe TagSelector::HolidayService, type: :service do
  let!(:group) { TagGroup.create!(name: "Holidays", system: true) }
  let!(:christmas_tag)      { Tag.create!(name: "Christmas",       tag_group: group, system: true) }
  let!(:easter_tag)         { Tag.create!(name: "Easter",          tag_group: group, system: true) }
  let!(:valentines_tag)     { Tag.create!(name: "Valentine's Day", tag_group: group, system: true) }
  let!(:new_years_eve_tag)  { Tag.create!(name: "New Year's Eve",  tag_group: group, system: true) }

  describe ".tags" do
    context "Christmas window" do
      it "returns Christmas tag on Christmas Day" do
        expect(described_class.tags(Date.new(2025, 12, 25))).to eq([ christmas_tag ])
      end

      it "returns Christmas tag within 3 weeks before" do
        expect(described_class.tags(Date.new(2025, 12, 10))).to eq([ christmas_tag ])
      end

      it "returns Christmas tag within 10 days after" do
        expect(described_class.tags(Date.new(2025, 12, 30))).to eq([ christmas_tag ])
      end
    end

    context "Easter window" do
      let(:easter_2025) { described_class.send(:easter_sunday, 2025) }

      it "returns Easter tag on Easter Sunday" do
        expect(described_class.tags(easter_2025)).to eq([ easter_tag ])
      end

      it "returns Easter tag within a week before" do
        expect(described_class.tags(easter_2025 - 3)).to eq([ easter_tag ])
      end

      it "returns Easter tag one day after" do
        expect(described_class.tags(easter_2025 + 1)).to eq([ easter_tag ])
      end
    end

    context "Valentine's Day" do
      it "returns Valentine's Day tag on February 14" do
        expect(described_class.tags(Date.new(2025, 2, 14))).to eq([ valentines_tag ])
      end
    end

    context "New Year's Eve / Day" do
      it "returns New Year's Eve tag on December 31" do
        tags = described_class.tags(Date.new(2025, 12, 31))
        expect(tags).to include(new_years_eve_tag)
      end

      it "returns New Year's Eve tag on January 1" do
        tags = described_class.tags(Date.new(2026, 1, 1))
        expect(tags).to include(new_years_eve_tag)
      end
    end

    context "Multiple overlapping holidays" do
      it "returns both Christmas and New Year's Eve tags on December 31" do
        tags = described_class.tags(Date.new(2025, 12, 31))
        expect(tags).to match_array([ christmas_tag, new_years_eve_tag ])
      end
    end

    context "No holiday" do
      it "returns empty array on a normal date" do
        expect(described_class.tags(Date.new(2025, 8, 15))).to eq([])
      end
    end
  end
end
