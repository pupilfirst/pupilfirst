json.array! @users do |user|
  json.email user.email
  json.status user.cofounder_status(current_user.startup)
end
