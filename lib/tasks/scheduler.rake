desc "This task is called by the Heroku scheduler add-on"
task :send_monthly_newsletter => :environment do
  puts "Sending Newsletters"
  User.send_monthly_emails
  puts "done."
end