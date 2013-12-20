path = "#{__FILE__.match(/v\d/)[0]}/events/event"
json.array! @events do |event|
	json.partial! path, event: event
end
