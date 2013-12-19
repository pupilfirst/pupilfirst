json.(news, :id, :title, :featured, :youtube_id)
json.body news.body if details_level == :full
if news.youtube_id.present?
	json.picture_url news.youtube_thumbnail_url
else
	json.picture_url news.picture_url
end
json.created_at fmt_time(news.created_at)
path = "#{__FILE__.match(/v\d/)[0]}/users/user"
json.author do
	json.partial! path, user: news.author
end
