class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user

  def content_preview
    "#{content[0..20]}..."
  end
end