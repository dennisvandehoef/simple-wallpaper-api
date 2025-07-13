class RemoveTitleFromImages < ActiveRecord::Migration[8.0]
  def change
    remove_column :images, :title, :string
  end
end
