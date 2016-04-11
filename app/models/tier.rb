class Tier < ActiveRecord::Base
  has_many :users

  validates :name, :admin_projects, :users_per_project, presence: true
  validates :name, uniqueness: true

  def permit_user_project(admin)
    admin.active_admin_projects.length < admin_projects
  end

  def permit_project_user(project)
    project.non_owner_users.count < users_per_project
  end

  def self.all_published
    all.where(published: true)
  end

  def find_subscription_by_type(yearly)
    yearly ? yearly_id : monthly_id
  end
end