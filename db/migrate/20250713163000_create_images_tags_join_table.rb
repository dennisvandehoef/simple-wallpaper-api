class CreateImagesTagsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :images, :tags do |t|
      t.index [ :image_id, :tag_id ], unique: true
      t.index [ :tag_id, :image_id ]
    end
  end
end
