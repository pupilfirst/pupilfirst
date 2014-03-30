
images = ['http://technoparktbi.files.wordpress.com/2012/06/start-up-village.jpg', 'http://www.topnews.in/files/Startup-Village02200.jpg', 'http://dd508hmafkqws.cloudfront.net/sites/default/files/styles/article_node_view/public/start%20up%20village.JPG']
images = images * 2
(1..4).each do |t|
  Event.seed do |e|
    e.id = t
    e.title = 'event ' + t.to_s
    e.description = "description #{t}"
    e.start_at = Time.now
    e.end_at = Time.now
    e.featured = rand(4) > 2 ? true : false
    e.location_id = 1
    e.remote_picture_url = images[t-1]
  end
end

