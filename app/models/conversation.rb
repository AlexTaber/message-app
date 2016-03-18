class Conversation < ActiveRecord::Base
  has_secure_token

  has_many :conversers
  has_many :users, through: :conversers
  has_many :messages
  has_many :tasks, through: :messages
  belongs_to :project

  validates :project_id, presence: true

  def content_preview(length)
    messages.last.content_preview(length)
  end

  def other_users_to_s(user, first_names_only = false)
    str = ""
    other_users(user).each { |user| first_names_only ? str += "#{user.first_name}, " : str += "#{user.name}, " }
    str[0...-2]
  end

  def abbreviated_other_users_to_s(user, length, first_names_only = false)
    str = other_users_to_s(user, first_names_only)
    str.length > length ? "#{str[0...length]}..." : str[0...length]
  end

  def other_users(user)
    users.select { |checked_user| checked_user != user }
  end

  def has_messages?
    messages.count > 0
  end

  def set_json(user)
    json = {}
    json[:other_users] = other_users(user).map(&:name)
    json[:messages] = messages.map { |message| message.set_json }
    json
  end

  def other_user_name(user)
    other_users = other_users(user)
    other_users.count > 1 ? "everyone" : other_users.first.first_name
  end

  def self.find_conversation_by_users_and_project(users, project)
    users ? project.find_conversation_by_users(users) : nil
  end

  def read_all_messages(user)
    messages.each { |message| message.read(user) unless message.user == user }
  end

  def has_unread_messages?(user)
    messages.count > 0 ? !messages.last.is_read_by?(user) : false
  end

  def has_users?
    users.length > 0
  end

  def self.ordered_conversations(conversations)
    conversations.sort_by { |conversation| conversation.messages.last.updated_at }.reverse!
  end

  def completed_tasks
    tasks.where(completed: true)
  end

  def pending_tasks
    tasks.where(completed: false)
  end

  def sorted_pending_tasks
    pending_tasks.sort{ |a,b| b.message.created_at <=> a.message.created_at }
  end

  def sorted_completed_tasks
    completed_tasks.sort{ |a,b| b.message.created_at <=> a.message.created_at }
  end

  def has_pending_tasks?
    pending_tasks.count > 0
  end

  def has_completed_tasks?
    completed_tasks.count > 0
  end

  def lazy_load_messages(index)
    start_index = index * 15
    end_index = start_index + 15
    lazy_messages = messages.order(created_at: :desc)[start_index...end_index]
    lazy_messages ? lazy_messages.reverse : []
  end
end