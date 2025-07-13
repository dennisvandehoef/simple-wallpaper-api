class TagGroup < ApplicationRecord
  has_many :tags, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # Prevent name changes for system groups
  before_update :prevent_system_modification, if: :system?

  private

  def prevent_system_modification
    if system_changed? || name_changed?
      errors.add(:base, "System tag groups cannot be modified")
      throw(:abort)
    end
  end
end
