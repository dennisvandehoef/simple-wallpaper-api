class CreateTagGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_groups do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :tag_groups, :name, unique: true
  end
end
