class Site < ActiveRecord::Base
  has_many :conversations
  has_many :user_sites
  has_many :users, through: :user_sites

  def has_conversations?
    conversations.count > 0
  end

  def other_users(user)
    users.where.not(id: user.id)
  end
end