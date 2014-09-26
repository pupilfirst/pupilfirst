json.(startup, :id, :logo_url, :pitch, :cool_fact, :website, :about, :email, :phone, :twitter_link, :facebook_link, :approval_status, :product_name, :product_description, :registration_type, :address, :state, :district, :incubation_location)
json.name   (startup.name or "My Startup")
json.categories     startup.categories.map &:name
json.created_at     fmt_time(startup.created_at)

# categories_v2 lists categories as they should have been listed in the first place - as an object array.
json.categories_v2  startup.categories, :id, :name, :category_type

valid_and_verified_founders = startup.founders.select { |f| f.verified? and f.valid? }

json.founders(valid_and_verified_founders) do |founder|
  path = "#{__FILE__.match(/v\d/)[0]}/startups/founder"
  json.partial! path, founder: founder
end
