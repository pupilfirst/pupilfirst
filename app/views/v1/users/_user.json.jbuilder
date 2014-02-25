json.(user, :id, :avatar_url, :fullname)
extra_block.call(user) if defined?(extra_block) and extra_block

if user.startup
	json.startup do
		path = "#{__FILE__.match(/v\d/)[0]}/startups/startup"
		json.partial! path, startup: user.startup
	end
else
	json.startup nil
end
