json.array! @events do |e|
	json.(e, :title, :featured, :picture_url)
	json.start_at 	fmt_time(e.start_at)
	json.end_at 		fmt_time(e.end_at)
	location_block = -> {
		json.title 				e.location.title
		json.latitude 		e.location.latitude
		json.longitude		e.location.longitude
		json.address 			e.location.address
	}
	json.location do
		e.location.present? ? location_block.call : nil
	end
end
