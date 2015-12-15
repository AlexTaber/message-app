class Site < ActiveRecord:Base
  has_many :conversations
  has_many :sites_users
  has_many :sites, through: :sites_users
end