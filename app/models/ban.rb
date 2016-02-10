class Ban < ActiveRecord::Base
  belongs_to :user

  def expired
    expiration < Date.today
  end

  def not_expired
    !expired
  end
end