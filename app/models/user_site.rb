class UserSite < ActiveRecord::Base
  belongs_to :user
  belongs_to :site

  validates :site_id, :user_id, presence: true
end