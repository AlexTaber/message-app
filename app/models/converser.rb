class Converser < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation

  validates :user_id, presence: true
end