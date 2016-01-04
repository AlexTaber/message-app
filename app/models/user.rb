class User < ActiveRecord::Base
  has_secure_password

  has_many :user_sites
  has_many :sites, through: :user_sites
  has_many :messages
  has_many :conversers
  has_many :conversations, through: :conversers
  has_one  :image, as: :imageable
  has_many :message_users
  has_many :recieved_messages, through: :message_users, source: :message
  has_many :notifications

  has_many :requests
  has_many :receivers, through: :requests
  has_many :inverse_requests, class_name: "Request", foreign_key: "receiver_id"
  has_many :inverse_receivers, through: :inverse_requests, source: :user

  def name
    "#{first_name} #{last_name}"
  end

  def conversations_by_site(site)
    conversations.where(site_id: site.id)
  end

  def has_conversations_by_site?(site)
    conversations_by_site(site).count > 0
  end

  def has_sites?
    sites.count > 0
  end

  def self.all_other_users(user)
    User.where.not(id: user.id)
  end

  def admin_of_site?(site)
    user_site = user_sites.find_by(site_id: site.id)
    user_site ? user_site.admin : false
  end

  def find_site_by_url(query_url)
    sites.find { |site| query_url.include?(site.url) }
  end

  def conversations_to_json(site)
    conversations_json = []
    conversations_by_site(site).each_with_index { |conversation, index| conversations_json[index] = conversation.set_json(self) }
    conversations_json
  end

  def ordered_conversations_by_site(site)
    Conversation.ordered_conversations(conversations_by_site(site))
  end

  def unread_notifications
    notifications.where(read: false)
  end

  def has_unread_notifications?
    unread_notifications.count > 0
  end

  def unread_conversations_by_site(site)
    conversations_by_site(site).select { |conversation| conversation.has_unread_messages?(self) }
  end

  def has_unread_conversations_by_site?(site)
    unread_conversations_by_site(site).count > 0
  end

  def pending_request_by_site(site)
    requests.find_by(site_id: site.id, active: true)
  end

  def pending_received_requests
    inverse_requests.where(active: true)
  end
end