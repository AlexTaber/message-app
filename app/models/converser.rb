class Converser < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation

  validates :conversation_id, :user_id, presence: true
end