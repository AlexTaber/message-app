class UserProject < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :project_id, :user_id, presence: true

  def valid_and_allowed?
    valid? && allowed?
  end

  def allowed?
    user.tier.permit_user_project(user)
  end
end