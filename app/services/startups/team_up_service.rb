module Startups
  class TeamUpService
    def initialize(founders)
      @founders = founders
    end

    def team_up(name)
      raise I18n.t("services.team_up_service.must_be_on_the_same_level") unless @founders.joins(startup: :level).distinct('levels.id').pluck('levels.id').one?

      Startup.transaction do
        startup = Startup.create!(
          name: name,
          level: @founders.first.startup.level,
          tag_list: applicable_tags
        )

        # the new team formed should have all team coaches assigned for the current teams
        old_startup_faculty.each do |faculty|
          FacultyStartupEnrollment.create!(startup: startup, faculty: faculty, safe_to_create: true)
        end

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

    private

    def applicable_tags
      Startup.where(id: old_startup_ids).distinct.joins(:tags).pluck('tags.name')
    end

    def old_startup_faculty
      current_faculty_enrollments = FacultyStartupEnrollment.where(startup_id: old_startup_ids)
      Faculty.where(id: current_faculty_enrollments.select(:faculty_id).distinct)
    end

    def old_startup_ids
      @old_startup_ids ||= @founders.pluck(:startup_id)
    end
  end
end
