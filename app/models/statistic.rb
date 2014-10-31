class Statistic < ActiveRecord::Base
  PARAMETER_COUNT_USERS = 'count_users'
  PARAMETER_COUNT_STARTUPS = 'count_startups'
  PARAMETER_COUNT_STARTUPS_UNREADY = 'count_startups_unready'
  PARAMETER_COUNT_STARTUPS_PENDING = 'count_startups_pending'
  PARAMETER_COUNT_STARTUPS_APPROVED = 'count_startups_approved'
  PARAMETER_COUNT_STARTUPS_REJECTED = 'count_startups_rejected'

  def self.valid_parameters
    [PARAMETER_COUNT_USERS, PARAMETER_COUNT_STARTUPS, PARAMETER_COUNT_STARTUPS_UNREADY, PARAMETER_COUNT_STARTUPS_PENDING, PARAMETER_COUNT_STARTUPS_APPROVED, PARAMETER_COUNT_STARTUPS_REJECTED]
  end

  validates_inclusion_of :parameter, in: valid_parameters
  validates_presence_of :statistic

  serialize :statistic, JSON

  def self.chartkick_parameter_by_date(parameter)
    where(parameter: parameter).inject({}) do |stats, statistic|
      stats[statistic.created_at] = statistic.statistic
      stats
    end
  end
end
