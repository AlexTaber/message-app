class User < ActiveRecord::Base
  has_many :sites_users
  has_many :sites, through: :sites_users
  has_many :messages
  has_many :conversations_users
  has_many :conversations, through: :conversations_users
end