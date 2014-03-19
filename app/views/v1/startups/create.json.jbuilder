path = "#{__FILE__.match(/v\d/)[0]}/users/user"
json.user do
  json.partial! path, user: @current_user, details_level: :full
end
