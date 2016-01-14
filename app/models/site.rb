class Site < ActiveRecord::Base
  has_secure_token

  has_many :conversations
  has_many :user_sites
  has_many :users, through: :user_sites
  has_many :requests

  def has_conversations?
    conversations.count > 0
  end

  def other_users(user)
    users.where.not(id: user.id)
  end

  def find_conversation_by_users(users)
    conversations.find { |conversation| conversation.user_ids.sort == users.map(&:id).sort }
  end

  def ordered_conversations
    conversations.sort_by { |conversation| conversation.messages.last.updated_at }.reverse!
  end

  def find_admin
    user_sites.find_by(admin: true)
  end

  def typeahead_users_data
    users.map(&:typeahead_data)
  end

  def pending_requests
    requests.where(active: true)
  end

  def has_pending_requests?
    pending_requests.count > 0
  end
end