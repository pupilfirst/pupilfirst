class CollectStatisticsJob < ActiveJob::Base
  queue_as :default

  def perform
    # Count of users
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_USERS,
      statistic: User.count
    )

    # Count of student users
    # @see https://trello.com/c/zpsSaRw8
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_USERS_STUDENT_ENTREPRENEURS,
      statistic: User.student_entrepreneurs.count
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

    Startup.valid_incubation_location_values.each do |incubation_location|
      # Count of 'pending' startups
      Statistic.create!(
        parameter: Statistic::PARAMETER_COUNT_STARTUPS_PENDING,
        statistic: Startup.where(incubation_location: incubation_location).pending.count,
        incubation_location: incubation_location
      )

      # Count of 'accepted' startups
      Statistic.create!(
        parameter: Statistic::PARAMETER_COUNT_STARTUPS_APPROVED,
        statistic: Startup.where(incubation_location: incubation_location).approved.count,
        incubation_location: incubation_location
      )

      # Count of 'rejected' startups
      Statistic.create!(
        parameter: Statistic::PARAMETER_COUNT_STARTUPS_REJECTED,
        statistic: Startup.where(incubation_location: incubation_location).rejected.count,
        incubation_location: incubation_location
      )

      # Number of startups that have a live agreement.
      # @see https://trello.com/c/zpsSaRw8
      Statistic.create!(
        parameter: Statistic::PARAMETER_COUNT_STARTUPS_LIVE_AGREEMENT,
        statistic: Startup.where(incubation_location: incubation_location).agreement_live.count,
        incubation_location: incubation_location
      )
    end

    # Number of startups that have signed an agreement. Kochi needs to be out of the loop (below) since it's calculation
    # is slightly different.
    # @see https://trello.com/c/SzqE6l8U
    Statistic.create!(
      parameter: Statistic::PARAMETER_COUNT_STARTUPS_AGREEMENT_SIGNED,
      statistic: (Startup::LEGACY_STARTUPS_COUNT + Startup.where(incubation_location: Startup::INCUBATION_LOCATION_KOCHI).agreement_signed_filtered.count),
      incubation_location: Startup::INCUBATION_LOCATION_KOCHI
    )

    (Startup.valid_incubation_location_values - [Startup::INCUBATION_LOCATION_KOCHI]).each do |incubation_location|
      Statistic.create!(
        parameter: Statistic::PARAMETER_COUNT_STARTUPS_AGREEMENT_SIGNED,
        statistic: Startup.where(incubation_location: incubation_location).agreement_signed.count,
        incubation_location: incubation_location
      )
    end
  end
end
