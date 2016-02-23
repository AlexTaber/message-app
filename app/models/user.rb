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
  has_one  :subscription
  has_many :password_recoveries
  has_many :bans

  has_many :requests

  has_many :invites
  belongs_to :tier

  validates :username, :first_name, :last_name, :email, :password_digest, presence: true
  validates :email, :username, uniqueness: true
  validates :username, length: { minimum: 5 }
  validates :first_name, :last_name, :email, length: { minimum: 1 }
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create

  def name
    "#{first_name} #{last_name}"
  end

  def last_initial
    "#{last_name[0]}."
  end

  def first_name_last_initial
    "#{first_name} #{last_initial}"
  end

  def messages_by_site(site)
    messages.select{ |message| message.conversation.site_id == site.id }
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
    user_sites.where(approved: true).collect(&:site).select(&:active)
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

  def unread_conversations
    conversations.select { |conversation| conversation.has_unread_messages?(self) }
  end

  def has_unread_conversations?
    unread_conversations.count > 0
  end

  def unread_conversations_count
    unread_conversations.count
  end

  def unread_conversations_by_site(site)
    conversations_by_site(site).select { |conversation| conversation.has_unread_messages?(self) }
  end

  def has_unread_conversations_by_site?(site)
    unread_conversations_by_site(site).count > 0
  end

  def unread_conversations_other_sites(site)
    conversations.where.not(site_id: site.id).select { |conversation| conversation.has_unread_messages?(self)}
  end

  def has_unread_conversations_other_sites?(site)
    unread_conversations_other_sites(site).count > 0
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
    { username: username, id: id, name: name }
  end

  def active_sites_ordered_by_admin
    user_sites.where(approved: true).order(admin: :desc).collect(&:site).select(&:active)
  end

  def unapproved_sites
    user_sites.where(approved: false).collect(&:site).select(&:active)
  end

  def has_unapproved_sites?
    unapproved_sites.count > 0;
  end

  def self.send_monthly_emails
    all.each(&:send_monthly_email)
  end

  def send_monthly_email
    UserMailer.monthly_email(self).deliver_now
  end

  def is_member_of_site?(site)
    user_sites.where(site_id: site.id).count > 0
  end

  def is_not_member_of_site?(site)
    !is_member_of_site?(site)
  end

  def pending_request_by_site(site)
    requests.find_by(site_id: site.id)
  end

  def has_request_for_site?(site)
    requests.where(site_id: site.id).count > 0
  end

  def has_no_requests_for_site?(site)
    !has_request_for_site?(site)
  end

  def can_send_request(potential_request)
    return false unless potential_request.valid?
    return false if is_member_of_site?(potential_request.site)
    has_no_requests_for_site?(potential_request.site)
  end

  def confirm_password(checked_password)
    checked_password ? checked_password == password : true
  end

  def invalidate_password_recoveries
    password_recoveries.each { |password_recovery| password_recovery.update_attributes(active: false) }
  end

  def current_ban
    active_bans.select(&:not_expired).first
  end

  def is_banned?
    current_ban ? true : false
  end

  def active_bans
    bans.where(active: true)
  end

  def valid_attribute?(attribute_name)
    self.valid?
    self.errors[attribute_name].blank?
  end

  def get_attribute_errors(attribute_name)
    self.valid?
    self.errors[attribute_name].join(", ")
  end

  def validation_response
    response = check_attributes
    response = { error: false } unless response
    response
  end

  def check_attributes
    attributes.keys.each do |attribute|
      response = check_attribute(attribute)
      return response if response
    end

    nil
  end

  def check_attribute(attribute)
    if send(attribute)
      { error: true, attribute: attribute.to_s, message: "#{attribute.capitalize} #{get_attribute_errors(attribute)}" } unless valid_attribute?(attribute)
    end
  end

  def remove_image
    image.delete
  end

  def needs_notification?
    !does_not_need_notification?
  end

  def does_not_need_notification?(message)
    recently_sent_message? || recently_online? || recently_messaged(message)
  end

  def recently_sent_message?
    message = messages.last
    message ? messages.last.is_recent? : false
  end

  def recently_online?
    last_online ? last_online > DateTime.now - 15.minutes : false
  end

  def recently_messaged(message)
    old_message = message.conversation.messages[-2]
    old_message ? old_message.is_recent? : false
  end
end