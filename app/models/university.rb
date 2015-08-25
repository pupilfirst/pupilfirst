class University < ActiveRecord::Base
  has_many :users
  validates_uniqueness_of :name, presence: true

  def to_label
  "#{name} #{location.present? ? " ["+location+"]" : ""}"
  end
end
