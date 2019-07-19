module Founders
  class MarkAsExitedService
    def initialize(founder_id)
      @students = Founder.where(id: founder_id)
    end

    def execute
      Founder.transaction do
        Startups::TeamUpService.new(@students).team_up(student.name)
        student.exited = true
        student.save
      end
    end

    private

    def student
      @student ||= @students.first
    end
  end
end
