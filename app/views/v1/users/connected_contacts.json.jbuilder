path = "#{__FILE__.match(/v\d/)[0]}/users/user"

extra_block = Proc.new do |user|
  json.phone user.phone
  json.company user.company
  json.designation user.designation
end

json.array! @connections do |connection|
  json.partial! path, user: connection.contact, details_level: :full, extra_block: extra_block
end
