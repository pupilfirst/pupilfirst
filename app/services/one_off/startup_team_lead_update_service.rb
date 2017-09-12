module OneOff
  class StartupTeamLeadUpdateService
    include Loggable
    def execute
      startups = Startup.all
      startups_without_admin = []
      updated_startups = []
      startups.each do |startup|
        if startup.admin.blank?
          startups_without_admin << startup.id
        else
          startup.update!(team_lead: startup.admin)
          updated_startups << startup.id
        end
      end

      log "#{updated_startups.count} startups were updated with team_lead"
      log "#{startups_without_admin.count} startups do not have admin. The ids are listed below:"
      startups_without_admin
    end
  end
end
