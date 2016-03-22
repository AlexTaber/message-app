class Task < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :message
  belongs_to :completer, class_name: "User"

  def status
    completed ? "Complete Task" : "Incomplete Task"
  end

  def html_class
    completed ? "complete" : "incomplete"
  end

  def user
    message.user
  end

  def content
    message.content
  end

  def from_recent_message?
    message.is_recent?
  end

  def completed_date_s
    "#{distance_of_time_in_words(DateTime.now, updated_at)} ago"
  end
end