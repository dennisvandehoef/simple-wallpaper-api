class AddSystemFlagToTagGroupsAndTags < ActiveRecord::Migration[7.1]
  def change
    add_column :tag_groups, :system, :boolean, null: false, default: false
    add_column :tags, :system, :boolean, null: false, default: false
  end
end
