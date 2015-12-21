class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  has_many :message_users
  has_many :recipients, through: :message_users, source: :user

  def content_preview(length)
    content.length > length ? "#{content[0...length]}..." : content[0...length]
  end

  def date_to_s
     created_at.strftime('%A, %B %d')
  end

  def time_to_s
    created_at.strftime('%l:%M%P')
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
    message_user.update_attribute(read: true) if message_user
  end

  def is_read_by?(checked_user)
    message_user = message_user_by_user(checked_user)
    message_user ? message_user.read : false
  end

  def message_user_by_user(recipient)
    message_users.find_by(user_id: recipient.id)
  end
end