json.(event, :id, :title, :featured)
json.picture_url     event.picture_url(:mid)
json.start_at 	fmt_time(event.start_at)
json.end_at 		fmt_time(event.end_at)
json.created_at 		fmt_time(event.created_at)
category_block = -> {
	json.id 				event.category.id
	json.name 			event.category.name
}
event.category.present? ? json.category {category_block.call} : json.category(nil)
location_block = -> {
	json.id 					event.location.id
	json.title 				event.location.title
	json.latitude 		event.location.latitude
	json.longitude		event.location.longitude
	json.address 			event.location.address
}
event.location.present? ? json.location {location_block.call} : json.location(nil)

path = "#{__FILE__.match(/v\d/)[0]}/users/user"
json.author do
	json.partial! path, user: event.author
end
