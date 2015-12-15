class Conversation < ActiveRecord::Base
  has_many :conversations_users
  has_many :users, through: :conversations_users
  has_many :messages
end