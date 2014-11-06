class Mentor < ActiveRecord::Base
  TIME_AVAILABILITY_MORNING_WEEKDAYS = 'morning_weekdays'
  TIME_AVAILABILITY_EVENING_WEEKDAYS = 'evening_weekdays'
  TIME_AVAILABILITY_MIDDAY_WEEKDAYS = 'midday_weekdays'
  TIME_AVAILABILITY_MIDDAY_WEEKENDS = 'midday_weekends'

  SKILL_PROGRAMMING = 'programming'
  SKILL_SALES = 'sales'
  SKILL_FINANCE = 'finance'

  CTC_BELOW_3L = 150000
  CTC_BETWEEN_3L_AND_6L = 450000
  CTC_BETWEEN_6L_AND_12L = 900000
  CTC_BETWEEN_12L_AND_36L = 2400000
  CTC_BETWEEN_36L_AND_1CR = 6800000
  CTC_ABOVE_1_CR = 10000000

  DONATE_100 = 100
  DONATE_75 = 75
  DONATE_50 = 50
  DONATE_25 = 25
  DONATE_0 = 0

  belongs_to :user
  belongs_to :company
  accepts_nested_attributes_for :user
  has_many :skills, class_name: 'MentorSkill'
end