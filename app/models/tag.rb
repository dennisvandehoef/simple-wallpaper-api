class Tag < ApplicationRecord
  belongs_to :tag_group

  validates :name, presence: true, uniqueness: { scope: :tag_group_id }

  before_update :prevent_system_modification, if: :system?
  before_destroy :prevent_system_modification, if: :system?

  private

  def prevent_system_modification
    errors.add(:base, "System tags cannot be modified or deleted")
    throw(:abort)
  end
end
