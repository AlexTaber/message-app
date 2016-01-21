class PasswordRecovery < ActiveRecord::Base
  has_secure_token

  belongs_to :user

  validates :user_id, presence: true
end