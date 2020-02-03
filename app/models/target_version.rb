class TargetVersion < ApplicationRecord
  belongs_to :target
  has_many :content_blocks, dependent: :destroy

  validates :version_at, presence: true
end
