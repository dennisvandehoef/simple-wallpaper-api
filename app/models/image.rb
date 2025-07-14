class Image < ApplicationRecord
  has_one_attached :file
  has_and_belongs_to_many :tags
end
