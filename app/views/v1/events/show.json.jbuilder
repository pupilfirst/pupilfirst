path = "#{__FILE__.match(/v\d/)[0]}/events/event"
json.partial! path, event: @event
