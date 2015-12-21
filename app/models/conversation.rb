class Conversation < ActiveRecord::Base
  has_many :conversers
  has_many :users, through: :conversers
  has_many :messages
  belongs_to :site

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

  def self.find_conversation_by_users_and_site(users, site)
    users ? site.find_conversation_by_users(users) : nil
  end

  def read_all_messages(user)
    messages.each { |message| message.read(user) unless message.user == user }
  end

  def has_unread_messages?(user)
    messages.count > 0 ? !messages.last.is_read_by?(user) : false
  end

  def has_users?
    users.count > 0
  end
end