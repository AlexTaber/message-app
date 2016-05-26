class Invite < ActiveRecord::Base
  has_secure_token

  belongs_to :user
  belongs_to :project

  validates :user_id, :project_id, :email, presence: true

  def can_be_sent?
    valid? && no_existing_user?  && not_duplicate?
  end

  def not_duplicate?
    !duplicate?
  end

  def duplicate?
    Invite.where("email = ? AND project_id = ?", email, project_id).size > 0
  end

  def no_existing_user?
    !existing_user
  end

  def existing_user
    User.find_by(email: email)
  end

  def create_user_project(user)
    UserProject.create(
      user_id: user.id,
      project_id: project.id,
      admin: false
    )

    delete
  end
end