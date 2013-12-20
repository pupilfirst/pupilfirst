json.(event, :id, :title, :featured, :picture_url)
json.start_at 	fmt_time(event.start_at)
json.end_at 		fmt_time(event.end_at)
json.created_at 		fmt_time(event.created_at)
category_block = -> {
	json.id 				event.category.id
	json.name 			event.category.name
}
json.category event.category.present? ? category_block.call : nil
location_block = -> {
	json.id 					event.location.id
	json.title 				event.location.title
	json.latitude 		event.location.latitude
	json.longitude		event.location.longitude
	json.address 			event.location.address
}
json.location event.location.present? ? location_block.call : nil

path = "#{__FILE__.match(/v\d/)[0]}/users/user"
json.author do
	json.partial! path, user: event.author
end
