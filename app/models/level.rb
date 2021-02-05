class Level < ApplicationRecord
  validates :number, uniqueness: { scope: :course_id }, presence: true
  validates :name, presence: true

  has_many :target_groups, dependent: :restrict_with_error
  has_many :startups, dependent: :restrict_with_error
  has_many :targets, through: :target_groups
  has_many :timeline_events, through: :targets

  scope :unlocked, -> { where(unlock_at: nil).or(where('unlock_at <= ?', Time.zone.now)) }

  belongs_to :course

  normalize_attribute :unlock_at

  def display_name
    "#{course.short_name}##{number}: #{name}"
  end

  def short_name
    I18n.t('shared.level_label.long_without_name', number: number.to_s)
  end

  def unlocked
    ActiveSupport::Deprecation.warn('Use `unlocked?` instead.')
    unlocked?
  end

  def unlocked?
    unlock_at.blank? || unlock_at.past?
  end
end
