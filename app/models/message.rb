class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user

  def content_preview
    "#{content[0..20]}..."
  end

  def date_to_s
     created_at.strftime('%A, %B %d')
  end

  def time_to_s
    created_at.strftime('%l:%M%P')
  end
end