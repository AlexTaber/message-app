class Conversation < ActiveRecord::Base
  has_many :conversers
  has_many :users, through: :conversers
  has_many :messages

  def content_preview
    messages.first.content_preview
  end
end