class ContentVersion < ApplicationRecord
  belongs_to :target
  belongs_to :content_block

  validates :sort_index, presence: true
  validates :version_on, presence: true
end
