# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
basic = Tier.create(
  name: "Basic",
  admin_sites: 1,
  users_per_site: 3
)

start_up = Tier.create(
  name: "Start Up",
  admin_sites: 1,
  users_per_site: 500
)

multi_site = Tier.create(
  name: "Multi Site",
  admin_sites: 5,
  users_per_site: 500
)

jerry = User.create(
  first_name: "Jerry",
  last_name: "Patterson",
  email: "info@peekskillwebdesign.com",
  password: "123",
  tier_id: multi_site.id
)

jerry_image = Image.create(
  url: "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png",
  imageable_type: "User",
  imageable_id: jerry.id
)

alex = User.create(
  first_name: "Alex",
  last_name: "Taber",
  email: "me@at.com",
  password: "123"
)

alex_image = Image.create(
  url: "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png",
  imageable_type: "User",
  imageable_id: alex.id
)

dan = User.create(
  first_name: "Dan",
  last_name: "Intriligator",
  email: "me@di.com",
  password: "123"
)

dan_image = Image.create(
  url: "http://www.cybersummitusa.com/site/wp-content/uploads/2014/01/avatar_blank.png",
  imageable_type: "User",
  imageable_id: dan.id
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

base = Site.create(
  name: "Base",
  url: "localhost:3000"
)

UserSite.create(user_id: jerry.id, site_id: base.id, admin: true)
UserSite.create(user_id: dan.id, site_id: base.id, admin: false)
UserSite.create(user_id: alex.id, site_id: base.id, admin: false)

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

  message_user = MessageUser.create(
    user_id: jerry.id,
    message_id: message.id
  )

  message = Message.create(
    user_id: jerry.id,
    conversation_id: convo.id,
    content: "Sup Dan, I heart #{site.name}"
  )

  message_user = MessageUser.create(
    user_id: dan.id,
    message_id: message.id
  )
end