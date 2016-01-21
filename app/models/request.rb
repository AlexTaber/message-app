class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :site

  validates :user_id, :site_id, presence: true
end