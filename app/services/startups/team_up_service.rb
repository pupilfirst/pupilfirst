module Startups
  class TeamUpService
    def initialize(founders)
      @founders = founders
    end

    def team_up(name)
      Startup.transaction do
        startup = Startup.create!(
          name: name,
          product_name: name,
          team_lead: @founders.first,
          level: @founders.first.startup.level
        )

        old_startup_ids = @founders.pluck(:startup_id)

        @founders.update(startup: startup)

        # Clean up old startups if they're empty.
        # TODO: There is an assumption here that startups without founders can be safely destroyed.
        # TODO: Nothing (except founders) should depend on a startup.
        Startup.where(id: old_startup_ids).each do |old_startup|
          old_startup.destroy! if old_startup.founders.count.zero?
        end

        startup
      end
    end
  end
end
