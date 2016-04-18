class Attachment < ActiveRecord::Base
  belongs_to :message

  def is_image?
    accepted_formats = ["png", "jpg", "jpeg", "gif"]
    extension = name.split(".").last

    accepted_formats.include?(extension)
  end
end