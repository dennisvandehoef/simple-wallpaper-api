class SeedDaytimeTags < ActiveRecord::Migration[8.0]
  def up
    group = TagGroup.find_or_create_by!(name: 'Daytime') { |g| g.system = true }
    %w[Day Night].each do |name|
      group.tags.find_or_create_by!(name: name) { |t| t.system = true }
    end
  end

  def down
    TagGroup.find_by(name: 'Daytime')&.destroy!
  end
end
