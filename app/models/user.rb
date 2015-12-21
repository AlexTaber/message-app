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

end