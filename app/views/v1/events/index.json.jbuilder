json.array! @events do |e|
	json.(e, :id, :title, :featured, :picture_url)
	json.start_at 	fmt_time(e.start_at)
	json.end_at 		fmt_time(e.end_at)
	json.created_at 		fmt_time(e.created_at)
	json.category   		e.category.name
	location_block = -> {
		json.id 					e.location.id
		json.title 				e.location.title
		json.latitude 		e.location.latitude
		json.longitude		e.location.longitude
		json.address 			e.location.address
	}
	json.location do
		e.location.present? ? location_block.call : nil
	end
	path = "#{__FILE__.match(/v\d/)[0]}/users/user"
	json.author do
		json.partial! path, user: e.author
	end

end
