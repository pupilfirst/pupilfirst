path = "#{__FILE__.match(/v\d/)[0]}/users/user"

extra_block = Proc.new do |user|
  json.auth_token user.auth_token
  json.phone user.phone
  json.phone_verified user.phone_verified
end

json.partial! path, user: @user, details_level: :full, extra_block: extra_block
