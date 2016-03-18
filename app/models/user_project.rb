class UserProject < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :project_id, :user_id, presence: true
end