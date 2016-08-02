class ModuleChapter < ActiveRecord::Base
  belongs_to :course_module

  validates_presence_of :chapter_number, :name, :course_module_id
  validates_uniqueness_of :chapter_number, scope: :course_module_id

  serialize :links

  validate :serialized_links_is_properly_formatted

  def serialized_links_is_properly_formatted
    return if @serialized_links.blank?

    # ensure its a valid json
    begin
      json = JSON.parse(@serialized_links)
    rescue
      errors[:serialized_links] << 'is not a valid JSON'
      return false
    end

    # ensure key is title or url
    json.map(&:symbolize_keys).each do |link|
      next if link.keys == [:title, :url]
      errors[:serialized_links] << 'keys have to be title and url'
      return false
    end

    true
  end

  after_initialize :make_links_an_array

  def make_links_an_array
    self.links ||= []
  end

  before_save :ensure_links_is_an_array

  def ensure_links_is_an_array
    self.links = [] if links.nil?
  end

  def serialized_links
    @serialized_links || links.to_json
  end

  def serialized_links=(value)
    # without this, rails skips validations if no 'real' attribute is updated
    attribute_will_change!(:serialized_links)

    # 'value' is not yet validated as json. So rescue parse error and let validate catch it
    begin
      @serialized_links = value
      self.links = JSON.parse(value).map(&:symbolize_keys)
    rescue JSON::ParserError
      return
    end
  end
end
