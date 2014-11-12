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

    # Number of startups that have signed an agreement.
    # @see https://trello.com/c/SzqE6l8U
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS_AGREEMENT_SIGNED,
      statistic: (849 + Startup.agreement_signed_filtered.count)
    )
  end
end