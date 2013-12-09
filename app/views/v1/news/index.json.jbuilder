json.array! @news do |e|
	json.(e, :title, :featured, :picture_url)
	json.created_at fmt_time(e.created_at)
	json.author do
		json.(e.author, :avatar_url)
		json.fullname e.author.fullname
	end
end
