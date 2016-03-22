class Project < ActiveRecord::Base
  has_secure_token

  has_many :conversations
  has_many :user_projects
  has_many :users, through: :user_projects
  has_many :requests
  has_many :tasks, through: :conversations

  validates :name, presence: true
  validates :name, uniqueness: true

  def has_conversations?
    conversations.count > 0
  end

  def other_users(user)
    users.where.not(id: user.id)
  end

  def has_other_users?(user)
    other_users(user).count > 0
  end

  def non_member_users
    User.where.not(id: user_ids)
  end

  def find_conversation_by_users(users)
    conversations.find { |conversation| conversation.user_ids.sort == users.map(&:id).sort }
  end

  def ordered_conversations
    conversations.sort_by { |conversation| conversation.messages.last.updated_at }.reverse!
  end

  def find_admin
    user_projects.find_by(admin: true)
  end

  def typeahead_users_data(user)
    other_users(user).map(&:typeahead_data)
  end

  def non_member_users_data
    non_member_users.map(&:typeahead_data)
  end

  def pending_requests
    requests.where(active: true)
  end

  def has_pending_requests?
    pending_requests.count > 0
  end

  def has_alert?(user)
    has_pending_requests? || user.has_unread_conversations_by_project?(self)
  end

  def self.all_projects_data
    all.map(&:typeahead_data)
  end

  def typeahead_data
    { name: name, id: id }
  end

  def non_owner_users
    users.where(owner: false)
  end

  def incomplete_tasks
    tasks.where(completed: false)
  end

  def completed_tasks
    conversations.collect(&:completed_tasks)
  end

  def has_completed_tasks?
    completed_tasks > 0
  end

  def pending_tasks
    conversations.collect(&:pending_tasks)
  end

  def has_pending_tasks?
    pending_tasks > 0
  end
end