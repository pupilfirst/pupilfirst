json.(startup, :id, :logo_url, :pitch, :website, :about, :email, :phone, :twitter_link, :facebook_link)
json.name   (startup.name or "My Startup")
json.categories 		startup.categories.map &:name
json.created_at 		fmt_time(startup.created_at)
json.founders(startup.founders) do |founder|
	path = "#{__FILE__.match(/v\d/)[0]}/startups/founder"
	json.partial! path, founder: founder
end
