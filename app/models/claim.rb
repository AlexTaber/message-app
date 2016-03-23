class Claim < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  def user_name
    user.name
  end
end