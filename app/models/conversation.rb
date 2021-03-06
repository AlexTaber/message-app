class Conversation < ActiveRecord::Base
  has_secure_token

  has_many :conversers
  has_many :users, through: :conversers
  has_many :messages
  has_many :tasks, through: :messages
  belongs_to :project

  validates :project_id, presence: true

  def content_preview(length)
    has_messages? ? messages.last.content_preview(length) : "Start messaging now"
  end

  def notes_preview
    has_messages? ? messages.last.content : "Write notes for #{project.name} here"
  end

  def other_users_to_s(user, first_name_only = true)
    first_name_only ? name_method = :first_name : name_method = :name
    other_users(user).map(&name_method).join(', ')
  end

  def abbreviated_other_users_to_s(user, length, first_name_only = true)
    first_name_only ? name_method = :first_name : name_method = :name
    all_other_users = other_users(user)
    str = all_other_users[0...length].map(&name_method).join(', ')
    all_other_users.count > length ? "#{str} and #{all_other_users.count - length} other(s)" : str
  end

  def other_users(user)
    users.select { |checked_user| checked_user != user }
  end

  def has_other_users?(user)
    other_users(user).length > 0
  end

  def other_active_users(user)
    users.select { |checked_user| checked_user != user && checked_user.active_conversation?(self) }
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
    messages.where.not(user_id: user.id).each { |message| message.read(user) }
  end

  def has_unread_messages?(user)
    messages.count > 0 ? !messages.last.is_read_by?(user) : false
  end

  def has_users?
    users.length > 0
  end

  def self.ordered_conversations(conversations)
    conversations.sort_by { |conversation| conversation.last_updated }.reverse!
  end

  def last_updated
    has_messages? ? messages.last.updated_at : updated_at
  end

  def completed_tasks
    tasks.where.not(completer_id: nil)
  end

  def pending_tasks
    tasks.where(completer_id: nil)
  end

  def sorted_pending_tasks
    pending_tasks.sort_by(&:created_at)
  end

  def sorted_completed_tasks
    completed_tasks.order(updated_at: :desc)
  end

  def has_pending_tasks?
    pending_tasks.count > 0
  end

  def has_completed_tasks?
    completed_tasks.count > 0
  end

  def has_complete_and_incomplete_tasks?
    has_completed_tasks? && has_pending_tasks?
  end

  def lazy_load_messages(index, offset = 0)
    start_index = (index * 15) + offset
    lazy_messages = messages.order(created_at: :desc).offset(start_index).limit(15).reverse
    lazy_messages || []
  end

  def lazy_load_tasks(index, offset = 0)
    start_index = (index * 15) + offset
    lazy_tasks = sorted_completed_tasks.offset(start_index).limit(15)
    lazy_tasks || []
  end

  def has_active_project?
    project.active
  end

  def inactive_users
    users.select { |user| user.inactive_conversation?(self) }
  end

  def has_inactive_users?
    inactive_users.count > 0 && persisted?
  end

  def active_users
    users.select { |user| user.active_conversation?(self) }
  end

  def has_active_users?
    active_users.count > 0
  end

  def is_notes?
    users.count == 1 && !new_record?
  end

  def image
    has_messages? ? messages.last.user.image : nil
  end

  def image_char
    has_messages? ? messages.last.user.first_name[0] : users.first.first_name[0]
  end

  def user_is_member?(user)
    conversers.where(user_id: user.id).size > 0
  end

  def user_is_permitted?(user)
    new_record? ? true : user_is_member?(user)
  end

  def self.recent_count_by_days(number)
    where("created_at > ?", DateTime.now - number.days).count
  end

  def search_messages(query)
    messages.where("lower(content) LIKE ?", "%#{query.downcase}%")
  end

  def search_tasks(query)
    search_messages(query).includes(:task).where.not(tasks: { id: nil })
  end

  def other_project_users
    project.users.where.not(id: user_ids)
  end
end