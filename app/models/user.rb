class User < ActiveRecord::Base
  has_secure_password

  has_many :user_projects
  has_many :projects, through: :user_projects
  has_many :messages
  has_many :conversers
  has_many :conversations, through: :conversers
  has_one  :image, as: :imageable
  has_many :message_users
  has_many :recieved_messages, through: :message_users, source: :message
  has_many :notifications
  has_one  :subscription
  has_many :password_recoveries
  has_many :bans
  has_many :completions, foreign_key: "completer_id", class_name: "Task"
  has_many :claims

  has_many :requests

  has_many :invites
  belongs_to :tier

  validates :username, :first_name, :last_name, :email, :password_digest, presence: true
  validates :email, :username, uniqueness: true
  validates :username, length: { minimum: 5 }
  validates :first_name, :last_name, :email, length: { minimum: 1 }
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create

  def name
    "#{first_name} #{last_name}"
  end

  def last_initial
    "#{last_name[0]}."
  end

  def first_name_last_initial
    "#{first_name} #{last_initial}"
  end

  def messages_by_project(project)
    messages.select{ |message| message.conversation.project_id == project.id }
  end

  def conversations_by_project(project)
    non_note_conversations.select { |conversation| conversation.project_id == project.id }
  end

  def has_conversations_by_project?(project)
    conversations_by_project(project).size > 0
  end

  def has_projects?
    projects.size > 0
  end

  def active_projects
    user_projects.where(approved: true).collect(&:project).select(&:active)
  end

  def has_active_projects?
    active_projects.size > 0
  end

  def self.all_other_users(user)
    User.where.not(id: user.id)
  end

  def self.all_other_users_data(user)
    self.all_other_users(user).map(&:typeahead_data)
  end

  def admin_of_project?(project)
    user_project = user_projects.find_by(project_id: project.id)
    user_project ? user_project.admin : false
  end

  def conversations_to_json(project)
    conversations_json = []
    conversations_by_project(project).each_with_index { |conversation, index| conversations_json[index] = conversation.set_json(self) }
    conversations_json
  end

  def ordered_conversations_by_project(project)
    Conversation.ordered_conversations(conversations_by_project(project))
  end

  def unread_notifications
    notifications.where(read: false)
  end

  def has_unread_notifications?
    unread_notifications.size > 0
  end

  def unread_conversations
    active_conversations.select { |conversation| conversation.has_unread_messages?(self) }
  end

  def active_conversations
    conversations.select(&:has_active_project?)
  end

  def has_unread_conversations?
    unread_conversations.size > 0
  end

  def unread_conversations_count
    unread_conversations.size
  end

  def unread_conversations_by_project(project)
    conversations_by_project(project).select { |conversation| conversation.has_unread_messages?(self) }
  end

  def has_unread_conversations_by_project?(project)
    unread_conversations_by_project(project).size > 0
  end

  def unread_conversations_other_projects(project)
    conversations.where.not(project_id: project.id).select { |conversation| conversation.has_unread_messages?(self)}
  end

  def has_unread_conversations_other_projects?(project)
    unread_conversations_other_projects(project).size > 0
  end

  def can_create_project
    tier.permit_user_project(self)
  end

  def can_add_user_to_project(project)
    tier.permit_project_user(project)
  end

  def admin_projects
    user_projects.where(admin: true).map(&:project)
  end

  def active_admin_projects
    admin_projects.select(&:active)
  end

  def image_url
    image ? image.url : nil
  end

  def find_user_project(project)
    user_projects.find_by(project_id: project.id)
  end

  def add_visit
    update_attribute(:visits, visits + 1)
  end

  def first_visit?
    visits <= 1
  end

  def conversation_tokens
    conversations.pluck(:token)
  end

  def typeahead_data
    { username: username, id: id, name: name, image_url: image_url, typeahead: "#{name} (#{username})" }
  end

  def active_projects_ordered_by_admin
    user_projects.where(approved: true).order(admin: :desc).collect(&:project).select(&:active)
  end

  def unapproved_projects
    user_projects.where(approved: false).collect(&:project).select(&:active)
  end

  def has_unapproved_projects?
    unapproved_projects.size > 0;
  end

  def self.send_monthly_emails
    all.each(&:send_monthly_email)
  end

  def send_monthly_email
    UserMailer.monthly_email(self).deliver_now
  end

  def is_member_of_project?(project)
    user_projects.where(project_id: project.id).size > 0
  end

  def is_not_member_of_project?(project)
    !is_member_of_project?(project)
  end

  def pending_request_by_project(project)
    requests.find_by(project_id: project.id)
  end

  def has_request_for_project?(project)
    requests.where(project_id: project.id).size > 0
  end

  def has_no_requests_for_project?(project)
    !has_request_for_project?(project)
  end

  def can_send_request(potential_request)
    return false unless potential_request.valid?
    return false if is_member_of_project?(potential_request.project)
    has_no_requests_for_project?(potential_request.project)
  end

  def confirm_password(checked_password)
    checked_password ? checked_password == password : true
  end

  def invalidate_password_recoveries
    password_recoveries.each { |password_recovery| password_recovery.update_attributes(active: false) }
  end

  def current_ban
    active_bans.select(&:not_expired).first
  end

  def is_banned?
    current_ban ? true : false
  end

  def active_bans
    bans.where(active: true)
  end

  def valid_attribute?(attribute_name)
    self.valid?
    self.errors[attribute_name].blank?
  end

  def get_attribute_errors(attribute_name)
    self.valid?
    self.errors[attribute_name].join(", ")
  end

  def validation_response
    response = check_attributes
    response = { error: false } unless response
    response
  end

  def check_attributes
    attributes.keys.each do |attribute|
      response = check_attribute(attribute)
      return response if response
    end

    nil
  end

  def check_attribute(attribute)
    if send(attribute)
      { error: true, attribute: attribute.to_s, message: "#{attribute.capitalize} #{get_attribute_errors(attribute)}" } unless valid_attribute?(attribute)
    end
  end

  def remove_image
    image.delete
  end

  def needs_notification?(message)
    !does_not_need_notification?(message)
  end

  def does_not_need_notification?(message)
    recently_sent_message? || recently_online? || recently_messaged(message)
  end

  def needs_task_notification?(task)
    !does_not_need_task_notification?(task)
  end

  def does_not_need_task_notification?(task)
    does_not_need_notification?(task.message) || task.from_recent_message?
  end

  def recently_sent_message?
    message = messages.last
    message ? messages.last.is_recent? : false
  end

  def recently_online?
    last_online ? last_online > DateTime.now - 15.minutes : false
  end

  def recently_messaged(message)
    old_message = message.conversation.messages[-2]
    old_message ? old_message.is_recent? : false
  end

  def format_new_user
    assign_attributes(first_name: first_name.capitalize, last_name: last_name.capitalize, email: email.downcase)
  end

  def claim_from_task(task)
    claims.find_by(task_id: task.id)
  end

  def claimed?(task)
    claim_from_task(task) != nil
  end

  def unclaimed(task)
    !claimed(task)
  end

  def remaining_projects_count
    tier.admin_projects - active_admin_projects.size
  end

  def remaining_users_count(project)
    tier.users_per_project - project.invited_users_count
  end

  def active_conversation?(conversation)
    conversation.project ? user_projects.find_by(project_id: conversation.project.id) : false
  end

  def inactive_conversation?(conversation)
    !active_conversation?(conversation)
  end

  def non_note_conversations
    conversations.select { |conversation| conversation.users.size > 1 }
  end

  def permitted_on_project?(project)
    project.new_record? ? true : is_member_of_project?(project)
  end

  def self.recent_count_by_days(number)
    where("created_at > ?", DateTime.now - number.days).count
  end

  def self.recent_active_users(number)
    where("last_online > ?", DateTime.now - number.days)
  end

  def join_date
    created_at.strftime("%m/%d/%Y")
  end

  def update_last_online
    update_attributes(last_online: DateTime.now)
  end
end