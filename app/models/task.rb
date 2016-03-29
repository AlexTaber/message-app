class Task < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :message
  belongs_to :completer, class_name: "User"
  has_many :claims

  def has_claims?
    claims.count > 0
  end

  def status
    completer ? "Complete Task" : "Incomplete Task"
  end

  def html_class
    completer ? "complete" : "incomplete"
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

  def complete?
    completer_id != nil
  end

  def incomplete?
    !complete?
  end

  def completed_date_s
    "#{distance_of_time_in_words(DateTime.now, updated_at)} by #{completer.name}"
  end

  def abbreviated_claim_names
    "#{claims[0..1].map(&:user_name).join(", ")}#{extra_claim_names}"
  end

  def extra_claim_names
    claims.count > 2 ? " and #{claims.count - 2} more" : ""
  end

  def claim_text
    claims.count > 1 ? "#{abbreviated_claim_names} are working on this" : "#{abbreviated_claim_names} is working on this"
  end

  def update_conversation(conversation_id)
    message.update_attributes(conversation_id: conversation_id)
  end

  def delete_claims
    claims.each(&:delete)
  end
end