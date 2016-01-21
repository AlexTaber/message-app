class Tier < ActiveRecord::Base
  has_many :users

  validates :name, :admin_sites, :users_per_site, presence: true
  validates :name, uniqueness: true

  def permit_user_site(admin)
    admin.active_admin_sites.length < admin_sites
  end

  def permit_site_user(site)
    site.users.count < users_per_site
  end

  def self.all_published
    all.where(published: true)
  end
end