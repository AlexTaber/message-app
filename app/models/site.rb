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

  def find_conversation_by_users(users)
    conversations.find { |conversation| conversation.user_ids.sort == users.map(&:id).sort }
  end
end