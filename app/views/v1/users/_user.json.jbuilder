json.(user, :id, :avatar_url, :fullname, :email, :pending_startup_id, :is_student, :communication_address, :gender, :twitter_url, :linkedin_url, :state, :district, :pin)
json.categories user.categories, :id, :name, :category_type
json.college user.college, :id, :name
json.born_on user.born_on.nil? ? nil : fmt_time(user.born_on)
extra_block.call(user) if defined?(extra_block) and extra_block

if user.startup
  json.startup do
    path = "#{__FILE__.match(/v\d/)[0]}/startups/startup"
    json.partial! path, startup: user.startup
  end
else
  json.startup nil
end
