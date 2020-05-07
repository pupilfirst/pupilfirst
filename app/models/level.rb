class Level < ApplicationRecord
  validates :number, uniqueness: { scope: :course_id }, presence: true
  validates :name, presence: true

  has_many :target_groups, dependent: :restrict_with_error
  has_many :startups, dependent: :restrict_with_error
  has_many :targets, through: :target_groups
  has_many :timeline_events, through: :targets

  scope :unlocked, -> { where(unlock_on: nil).or(where('unlock_on <= ?', Time.zone.today)) }

  belongs_to :course

  normalize_attribute :unlock_on

  def display_name
    "#{course.short_name}##{number}: #{name}"
  end

  def short_name
    'Level ' + number.to_s
  end

  def unlocked
    ActiveSupport::Deprecation.warn('Use `unlocked?` instead.')
    unlocked?
  end

  def unlocked?
    !unlock_on&.future?
  end
end
