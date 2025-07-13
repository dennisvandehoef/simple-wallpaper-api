class Tag < ApplicationRecord
  belongs_to :tag_group

  validates :name, presence: true, uniqueness: { scope: :tag_group_id }
end
