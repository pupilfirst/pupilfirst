class Statistic < ActiveRecord::Base
  PARAMETER_COUNT_USERS = 'count_users'
  PARAMETER_COUNT_USERS_STUDENT_ENTREPRENEURS = 'count_users_student_entrepreneurs'

  PARAMETER_COUNT_STARTUPS = 'count_startups'
  PARAMETER_COUNT_STARTUPS_UNREADY = 'count_startups_unready'
  PARAMETER_COUNT_STARTUPS_PENDING = 'count_startups_pending'
  PARAMETER_COUNT_STARTUPS_APPROVED = 'count_startups_approved'
  PARAMETER_COUNT_STARTUPS_REJECTED = 'count_startups_rejected'
  PARAMETER_COUNT_STARTUPS_AGREEMENT_SIGNED = 'count_startups_agreement_signed'
  PARAMETER_COUNT_STARTUPS_LIVE_AGREEMENT = 'count_startups_live_agreement'

  def self.valid_parameters
    [
      PARAMETER_COUNT_USERS,
      PARAMETER_COUNT_USERS_STUDENT_ENTREPRENEURS,
      PARAMETER_COUNT_STARTUPS,
      PARAMETER_COUNT_STARTUPS_UNREADY,
      PARAMETER_COUNT_STARTUPS_PENDING,
      PARAMETER_COUNT_STARTUPS_APPROVED,
      PARAMETER_COUNT_STARTUPS_REJECTED,
      PARAMETER_COUNT_STARTUPS_AGREEMENT_SIGNED,
      PARAMETER_COUNT_STARTUPS_LIVE_AGREEMENT
    ]
  end

  validates_inclusion_of :parameter, in: valid_parameters
  validates_inclusion_of :incubation_location, in: Startup.valid_incubation_location_values, allow_nil: true
  validates_presence_of :statistic

  serialize :statistic, JSON

  def self.chartkick_parameter_by_date(parameter, incubation_location: nil)
    where(parameter: parameter, incubation_location: incubation_location).order('id DESC').limit(30).reverse.inject({}) do |stats, statistic|
      stats[statistic.created_at.strftime('%b %e, %Y')] = statistic.statistic
      stats
    end
  end
end
