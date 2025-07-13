class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :tag_group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, [:tag_group_id, :name], unique: true
  end
end
