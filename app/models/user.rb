class User < ActiveRecord::Base
  has_secure_password

  has_many :user_sites
  has_many :sites, through: :user_sites
  has_many :messages
  has_many :conversers
  has_many :conversations, through: :conversers

  def name
    "#{first_name} #{last_name}"
  end

  def conversations_by_site(site)
    conversations.where(site_id: site.id)
  end

  def has_sites?
    sites.count > 0
  end
end