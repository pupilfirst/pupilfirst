module Founders
  class BecomeTeamLeadService
    AlreadyTeamLeadException = Class.new(StandardError)
    NotMemberOfStartupException = Class.new(StandardError)

    def initialize(founder)
      @founder = founder
    end

    def execute
      raise AlreadyTeamLeadException if startup&.admin == @founder
      raise NotMemberOfStartupException if startup.blank? || !@founder.in?(startup.founders)

      Founder.transaction do
        startup.admin&.update!(startup_admin: false)
        @founder.update!(startup_admin: true)
      end
    end

    private

    def startup
      @startup ||= @founder.startup
    end
  end
end
