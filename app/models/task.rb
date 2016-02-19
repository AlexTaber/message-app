class Task < ActiveRecord::Base
  belongs_to :message

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
end