# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

jerry = User.create(
  first_name: "Jerry",
  last_name: "Patterson",
  email: "info@peekskillwebdesign.com",
  password: "123"
)

alex = User.create(
  first_name: "Alex",
  last_name: "Taber",
  email: "me@at.com",
  password: "123"
)

dan = User.create(
  first_name: "Dan",
  last_name: "Intriligator",
  email: "me@di.com",
  password: "123"
)

google = Site.create(
  name: "Google",
  url: "www.google.com"
)

UserSite.create(user_id: jerry.id, site_id: google.id, admin: true)
UserSite.create(user_id: dan.id, site_id: google.id, admin: false)
UserSite.create(user_id: alex.id, site_id: google.id, admin: false)

amazon = Site.create(
  name: "Amazon",
  url: "www.amazon.com"
)

UserSite.create(user_id: jerry.id, site_id: amazon.id, admin: true)
UserSite.create(user_id: dan.id, site_id: amazon.id, admin: false)
UserSite.create(user_id: alex.id, site_id: amazon.id, admin: false)

Site.all.each do |site|
  convo = Conversation.create(
    site_id: site.id
  )

  convo.users << jerry
  convo.users << dan

  message = Message.create(
    user_id: dan.id,
    conversation_id: convo.id,
    content: "Sup Jerry, I heart #{site.name}"
  )

  message = Message.create(
    user_id: jerry.id,
    conversation_id: convo.id,
    content: "Sup Dan, I heart #{site.name}"
  )
end