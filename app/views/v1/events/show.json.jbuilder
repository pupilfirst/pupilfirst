json.(@event, :id, :title, :description, :featured, :picture_url)
json.start_at 	fmt_time(@event.start_at)
json.end_at 		fmt_time(@event.end_at)
json.created_at fmt_time(@event.created_at)
location_block = -> {
	json.id 					@event.location.id
	json.title 				@event.location.title
	json.latitude 		@event.location.latitude
	json.longitude		@event.location.longitude
	json.address 			@event.location.address
}
json.location do
	@event.location.present? ? location_block.call : nil
end
path = "#{__FILE__.match(/v\d/)[0]}/users/user"
json.author do
	json.partial! path, user: @event.author
end
