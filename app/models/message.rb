class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  has_many :recipients, through: :message_users, class_name: "User"

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

  def is_read_by?(checked_user)
    user == checked_user || read
  end
end