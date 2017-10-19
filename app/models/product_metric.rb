class ProductMetric < ApplicationRecord
  VALID_CATEGORIES = {
    'Startups' => { automatic: true, delta_period: 3 },
    'Founders' => { automatic: true, delta_period: 3 },
    'Participating States' => { automatic: true },
    'Participating Universities' => { automatic: true },
    'Participating Colleges' => { automatic: true },
    'Student Explorers' => { automatic: true },
    'Student Alpha Engineers' => { automatic: true },
    'Student Beta Engineers' => { automatic: true },
    'Student Heroes' => { automatic: false },
    'Student Leadership Team Members' => { automatic: false },
    'Student Coaches' => { automatic: false },
    'Targets' => { automatic: true },
    'Faculty Sessions' => { automatic: true, delta_period: 6 },
    'Faculty Office Hours' => { automatic: true, delta_period: 3 },
    'Library Resources' => { automatic: true },
    'Library Resource Downloads' => { automatic: true, delta_period: 3 },
    'Slack Messages' => { automatic: true },
    'Graduation Partners' => { automatic: false },
    'Community Architects' => { automatic: false },
    'Blog Stories Published' => { automatic: false }
  }.freeze

  ASSIGNMENT_MODE_AUTOMATIC = -'automatic'
  ASSIGNMENT_MODE_MANUAL = -'manual'

  def self.valid_assignment_modes
    [ASSIGNMENT_MODE_AUTOMATIC, ASSIGNMENT_MODE_MANUAL].freeze
  end

  validates :delta_period, presence: true, if: proc { |pm| pm.delta_value.present? }

  validate :manual_assignment_requires_faculty

  def manual_assignment_requires_faculty
    return if assignment_mode == ASSIGNMENT_MODE_AUTOMATIC || faculty.present?
    errors[:faculty] << 'is required for manual assignment'
  end

  belongs_to :faculty, optional: true
end
