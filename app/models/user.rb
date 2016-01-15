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
  has_many :subscriptions
  has_many :password_recoveries

  has_many :requests

  has_many :invites
  belongs_to :tier

  def name
    "#{first_name} #{last_name}"
  end

  def last_initial
    "#{last_name[0]}."
  end

  def first_name_last_initial
    "#{first_name} #{last_initial}"
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

  def active_sites
    sites.where(active: true)
  end

  def has_active_sites?
    active_sites.count > 0
  end

  def self.all_other_users(user)
    User.where.not(id: user.id)
  end

  def self.all_other_users_data(user)
    self.all_other_users(user).map(&:typeahead_data)
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

  def can_create_site
    tier.permit_user_site(self)
  end

  def can_add_user_to_site(site)
    tier.permit_site_user(site)
  end

  def admin_sites
    user_sites.where(admin: true).map(&:site)
  end

  def active_admin_sites
    admin_sites.select(&:active)
  end

  def image_url
    image ? image.url : "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png"
  end

  def find_user_site(site)
    user_sites.find_by(site_id: site.id)
  end

  def add_visit
    update_attribute(:visits, visits + 1)
  end

  def first_visit?
    visits <= 1
  end

  def conversation_tokens
    conversations.pluck(:token)
  end

  def typeahead_data
    { id: id, name: name }
  end

  def active_sites_ordered_by_admin
    user_sites.order(admin: :desc).collect(&:site).select(&:active)
  end
end