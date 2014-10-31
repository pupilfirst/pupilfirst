namespace :statistics do
  desc 'Stores statistics in database.'
  task generate: [:environment] do
    # Count of users
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_USERS,
      statistic: User.count
    )

    # Count of startups
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS,
      statistic: Startup.count
    )

    # Count of 'unready' startups
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS_UNREADY,
      statistic: Startup.unready.count
    )

    # Count of 'pending' startups
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS_PENDING,
      statistic: Startup.pending.count
    )

    # Count of 'accepted' startups
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS_APPROVED,
      statistic: Startup.approved.count
    )

    # Count of 'rejected' startups
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS_REJECTED,
      statistic: Startup.rejected.count
    )
  end
end