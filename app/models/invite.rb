class Invite < ActiveRecord::Base
  has_secure_token

  belongs_to :user
  belongs_to :site

  validates :user_id, :site_id, :email, presence: true
end