json.(event, :id, :title, :featured)
json.picture_url     event.picture_url(:mid)
json.start_at   fmt_time(event.start_at)
json.end_at     fmt_time(event.end_at)
json.created_at     fmt_time(event.created_at)
category_block = -> {
  json.id         event.category.id
  json.name       event.category.name
}
event.category.present? ? json.category {category_block.call} : json.category(nil)

# TODO: Rest of location attributes will be sent as nil until how location is represented is clarified.
json.location {
  json.id nil
  json.title event.location
  json.latitude nil
  json.longitude nil
  json.address event.location
}

# TODO: Rest of author attributes will be sent as nil until how location is represented clarified.
json.author do
  json.id nil
  json.avatar_url nil
  json.fullname event.posters_name
end
