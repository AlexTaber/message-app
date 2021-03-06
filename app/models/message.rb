class Message < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :conversation
  belongs_to :user
  has_many :message_users
  has_many :recipients, through: :message_users, source: :user
  has_one :task
  has_many :attachments

  validates :user_id, :conversation_id, :content, presence: true

  def content_preview(length)
    content.length > length ? "#{content[0...length]}..." : content[0...length]
  end

  def date_to_s
     created_at.strftime('%A, %B %d')
  end

  def time_to_s
    created_at.strftime('%l:%M%P')
  end

  def time_ago_to_s
    "#{distance_of_time_in_words(DateTime.now, created_at)} ago"
  end

  def set_json
    json = {}
    json[:content] = content
    json[:user_name] = user.name
    json
  end

  def from_user?(checked_user)
    user.id == checked_user.id
  end

  def read(recipient)
    message_user = message_user_by_user(recipient)
    message_user.update_attribute(:read, true) if message_user
  end

  def is_read_by?(checked_user)
    message_user = message_user_by_user(checked_user)
    message_user ? message_user.read : true
  end

  def message_user_by_user(recipient)
    message_users.find_by(user_id: recipient.id)
  end

  def auto_linked_content
    Rinku.auto_link(content, :all, 'target="_blank"')
  end

  def is_recent?(inactive_time)
    created_at > DateTime.now - inactive_time.minutes
  end

  def delete_old_task
    task.delete if task
  end

  def has_task?
    task ? task.persisted? : false
  end

  def self.recent_count_by_days(number)
    where("created_at > ?", DateTime.now - number.days).count
  end

  def self.recent_non_owner_count_by_days(number)
    where("created_at > ?", DateTime.now - number.days).select(&:not_from_owner).count
  end

  def not_from_owner
    !from_owner
  end

  def from_owner
    user.owner
  end

  def has_attachments?
    attachments.size > 0
  end

  def default_content
    assign_attributes(content: "(No Content)") if content.empty?
  end

  def self.search(query)
    where("lower(content) LIKE ?", "#{query.downcase}")
  end

  def self.task_search(query)
    search(query).includes(:task).where(tasks: { id: nil })
  end
end