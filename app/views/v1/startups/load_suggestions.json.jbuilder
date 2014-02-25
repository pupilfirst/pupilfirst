json.array! @suggestions do |startup|
	json.(startup, :id, :name, :logo_url)
end
