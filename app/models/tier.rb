class Tier < ActiveRecord::Base
  has_many :users

  def permit_user_site(user)
    user.admin_sites.count < admin_sites
  end
end