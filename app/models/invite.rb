class Invite < ActiveRecord::Base
  has_secure_token

  belongs_to :user
  belongs_to :site
end