class News < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  belongs_to :category
  normalize_attributes :title, :body, :featured, :youtube_id, :picture, :published_at

  mount_uploader :picture, FeedImageUploader
  process_in_background :picture
  just_define_datetime_picker :published_at

  validates_presence_of :author
  validates_presence_of :category_id
  validates_presence_of :picture
  validates_presence_of :title
  alias_attribute :push_title, :title
  PUSH_TYPE = 'news'

  before_create do
    unless self.published_at.present?
      self.published_at = Time.now
    end
  end

  after_save do
    if featured_changed? and featured and not notification_sent
      PushNotifyJob.new.async.perform(self.class.to_s.downcase, self.id)
    end
  end

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
