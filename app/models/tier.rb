class Tier < ActiveRecord::Base
  has_many :users

  def permit_user_site(admin)
    admin.active_admin_sites.length < admin_sites
  end

  def permit_site_user(site)
    site.users.count < users_per_site
  end
end