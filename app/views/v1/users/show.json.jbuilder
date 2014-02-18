	path = "#{__FILE__.match(/v\d/)[0]}/users/user"
	json.partial! path, user: @user, details_level: :full
