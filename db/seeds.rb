# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
basic = Tier.create(
  name: "Personal",
  admin_projects: 3,
  users_per_project: 4
)

start_up = Tier.create(
  name: "Start Up",
  admin_projects: 5,
  users_per_project: 6
)

multi_project = Tier.create(
  name: "Enterprise",
  admin_projects: 15,
  users_per_project: 15
)

admin_tier = Tier.create(
  name: "Admin",
  admin_projects: 1001,
  users_per_project: 1000,
  published: false
)

jerry = User.create(
  username: "jerrypatterson",
  first_name: "Jerry",
  last_name: "Patterson",
  email: "info@peekskillwebdesign.com",
  password: "Pwd_2015",
  tier_id: admin_tier.id,
  owner: true
)

jerry_image = Image.create(
  url: "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png",
  imageable_type: "User",
  imageable_id: jerry.id
)

jerry_sub = Subscription.create(
  user_id: jerry.id
)

alex = User.create(
  username: "alextaber",
  first_name: "Alex",
  last_name: "Taber",
  email: "alex.taber0@gmail.com",
  password: "Pwd_2015",
  tier_id: admin_tier.id,
  owner: true
)

alex_sub = Subscription.create(
  user_id: alex.id
)

alex_image = Image.create(
  url: "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png",
  imageable_type: "User",
  imageable_id: alex.id
)

dan = User.create(
  username: "danintriligator",
  first_name: "Dan",
  last_name: "Intriligator",
  email: "daniel@peekskillwebdesign.com",
  password: "Pwd_2015",
  tier_id: admin_tier.id,
  owner: true
)

dan_image = Image.create(
  url: "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png",
  imageable_type: "User",
  imageable_id: dan.id
)

dan_sub = Subscription.create(
  user_id: dan.id
)

google = Project.create(
  name: "Google"
)

UserProject.create(user_id: jerry.id, project_id: google.id, admin: true, approved: true)
UserProject.create(user_id: dan.id, project_id: google.id, admin: false, approved: true)
UserProject.create(user_id: alex.id, project_id: google.id, admin: false, approved: true)

amazon = Project.create(
  name: "Amazon"
)

UserProject.create(user_id: jerry.id, project_id: amazon.id, admin: true, approved: true)
UserProject.create(user_id: dan.id, project_id: amazon.id, admin: false, approved: true)
UserProject.create(user_id: alex.id, project_id: amazon.id, admin: false, approved: true)

base = Project.create(
  name: "Base"
)

UserProject.create(user_id: jerry.id, project_id: base.id, admin: true, approved: true)
UserProject.create(user_id: dan.id, project_id: base.id, admin: false, approved: true)
UserProject.create(user_id: alex.id, project_id: base.id, admin: false, approved: false)

Project.all.each do |project|
  convo = Conversation.create(
    project_id: project.id
  )

  convo.users << jerry
  convo.users << dan

  message = Message.create(
    user_id: dan.id,
    conversation_id: convo.id,
    content: "Sup Jerry, I heart #{project.name}"
  )

  message_user = MessageUser.create(
    user_id: jerry.id,
    message_id: message.id
  )

  message = Message.create(
    user_id: jerry.id,
    conversation_id: convo.id,
    content: "Sup Dan, I heart #{project.name}"
  )

  message_user = MessageUser.create(
    user_id: dan.id,
    message_id: message.id
  )
end