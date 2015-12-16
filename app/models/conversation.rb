class Conversation < ActiveRecord::Base
  has_many :conversers
  has_many :users, through: :conversers
  has_many :messages

  def content_preview
    messages.first.content_preview
  end

  def other_users_to_s(user)
    str = ""
    other_users(user).each { |user| str += "#{user.name}, " }
    str[0...-2]
  end

  def other_users(user)
    users.select { |checked_user| checked_user != user }
  end
end