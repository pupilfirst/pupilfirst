module Founders
  class MarkAsExitedService
    def initialize(founder_id)
      @founder = Founder.where(id: founder_id)
    end

    def execute
      Founder.transaction do
        ::Startups::TeamUpService.new(@founder).team_up(@founder.name)
        @founder.update(exited: true)
      end
    end
  end
end
