class Invite < ActiveRecord::Base
  has_secure_token

  belongs_to :user
  belongs_to :site

  validates :user_id, :site_id, :email, presence: true

  def can_be_sent?
    valid? && no_existing_user?
  end

  def no_existing_user?
    !existing_user
  end

  def existing_user
    User.find_by(email: email)
  end
end