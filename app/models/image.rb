class Image < ApplicationRecord
  has_one_attached :file
  has_and_belongs_to_many :tags

  GRAVITIES = %w[Center North South East West NorthEast NorthWest SouthEast SouthWest Entropy Attention].freeze

  validates :crop_gravity, inclusion: { in: GRAVITIES }
end
