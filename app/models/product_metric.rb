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
    'Faculty Sessions' => { automatic: true, delta_period: 3 },
    'Faculty Sessions Recorded Minutes Watched' => { automatic: false },
    'Faculty Office Hours' => { automatic: true, delta_period: 3 },
    'Library Resources' => { automatic: true },
    'Library Resource Downloads' => { automatic: true, delta_period: 3 },
    'Slack Conversations' => { automatic: false },
    'Graduation Partners' => { automatic: false },
    'Community Architects' => { automatic: false },
    'Blog Stories Published' => { automatic: false },
    'Time Spent on Website' => { automatic: true, delta_period: 3 },
    'Time Spent on Public Slack' => { automatic: false }
  }.freeze

  belongs_to :faculty, optional: true
end
