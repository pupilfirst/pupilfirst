	path = "#{__FILE__.match(/v\d/)[0]}/news/news"
	json.partial! path, news: @news, details_level: :full
