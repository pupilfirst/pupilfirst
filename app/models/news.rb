class News < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  normalize_attributes :title, :body, :featured, :youtube_id, :picture

  mount_uploader :picture, FeedImageUploader

  def youtube_thumbnail_url(size = :high)
  	case size
  	when :max
			"http://img.youtube.com/vi/#{youtube_id}/maxresdefault.jpg"
  	when :high
  		"http://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg"
  	when :mid
  		"http://img.youtube.com/vi/#{youtube_id}/mqdefault.jpg"
  	when :low
  		"http://img.youtube.com/vi/#{youtube_id}/default.jpg"
  	when :var0
  		"http://img.youtube.com/vi/#{youtube_id}/0.jpg"
  	when :var1
  		"http://img.youtube.com/vi/#{youtube_id}/1.jpg"
  	when :var2
  		"http://img.youtube.com/vi/#{youtube_id}/3.jpg"
  	when :var3
  		"http://img.youtube.com/vi/#{youtube_id}/4.jpg"
  	else
  		"http://img.youtube.com/vi/#{youtube_id}/default.jpg"
  	end
  end
end
