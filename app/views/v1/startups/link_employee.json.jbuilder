path = "#{__FILE__.match(/v\d/)[0]}/users/user"
json.partial! path, user: @new_employee, details_level: :full
