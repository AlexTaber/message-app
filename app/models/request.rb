class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :receiver, class_name: "User"
  belongs_to :site
end