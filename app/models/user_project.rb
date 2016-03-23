class UserProject < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :project_id, :user_id, presence: true

  def valid_and_allowed?
    valid? && allowed?
  end

  def allowed?
    admin ? user.tier.permit_user_project(user) : true
  end

  def not_allowed?
    !allowed?
  end

  def not_admin?
    !admin
  end
end