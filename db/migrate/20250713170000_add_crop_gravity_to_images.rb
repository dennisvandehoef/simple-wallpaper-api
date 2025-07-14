class AddCropGravityToImages < ActiveRecord::Migration[8.0]
  def change
    add_column :images, :crop_gravity, :string, null: false, default: 'Center'
  end
end
