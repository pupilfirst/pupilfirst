json.array! @categories do |category|
  json.id category.id
  json.name category.name
  json.category_type category.category_type
end
