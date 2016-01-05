class Tier < ActiveRecord::Base
  has_many :users
end