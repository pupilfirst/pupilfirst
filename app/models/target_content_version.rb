class TargetContentVersion < ApplicationRecord
  belongs_to :target
  validates :content_blocks, presence: true
end
