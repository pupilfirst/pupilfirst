images = ['http://technoparktbi.files.wordpress.com/2012/06/start-up-village.jpg', 'http://www.topnews.in/files/Startup-Village02200.jpg', 'http://dd508hmafkqws.cloudfront.net/sites/default/files/styles/article_node_view/public/start%20up%20village.JPG']
images = images * 2
(1..4).each do |t|
  News.seed(:id) do |e|
    e.id = t
    e.title = 'news ' + t.to_s
    e.body = "body #{t}"
    e.featured = rand(4) > 2 ? true : false
    e.user_id = [1,2].shuffle.first
    e.remote_picture_url = images[t-1]
  end
end
