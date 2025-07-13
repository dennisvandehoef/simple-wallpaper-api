class SeedSeasonAndHolidayTags < ActiveRecord::Migration[7.1]
  def up
    seed_group_with_tags("Seasons", %w[Spring Summer Fall Winter])
    seed_group_with_tags("Holidays", [
      "Christmas",
      "New Year's Eve",
      "Easter",
      "Valentine's Day"
    ])
  end

  def down
    TagGroup.where(name: ["Seasons", "Holidays"]).destroy_all
  end

  private

  def seed_group_with_tags(group_name, tags)
    group = TagGroup.find_or_create_by!(name: group_name) { |g| g.system = true }
    tags.each { |name| group.tags.find_or_create_by!(name: name) { |t| t.system = true } }
  end
end
