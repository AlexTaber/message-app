class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  validates :imageable_id, :imageable_type, :url, presence: true
end