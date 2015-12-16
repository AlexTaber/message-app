class Conversation < ActiveRecord::Base
  has_many :conversers
  has_many :users, through: :conversers
  has_many :messages
  belongs_to :site

  def content_preview(length)
    messages.first.content_preview(length)
  end

  def other_users_to_s(user)
    str = ""
    other_users(user).each { |user| str += "#{user.name}, " }
    str[0...-2]
  end

  def abbreviated_other_users_to_s(user, length)
    str = other_users_to_s(user)
    str.length > length ? "#{str[0...length]}..." : str[0...length]
  end

  def other_users(user)
    users.select { |checked_user| checked_user != user }
  end

  def has_messages?
    messages.count > 0
  end
end