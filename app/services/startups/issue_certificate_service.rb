module Startups
  class IssueCertificateService
    def initialize(team)
      @team = team
    end

    def execute
      return if active_certificate.blank?

      @team.founders.each do |student|
        Students::IssueCertificateService.new(student).issue
      end
    end

    private

    def course
      @course ||= @team.course
    end

    def active_certificate
      @active_certificate ||= course.certificates.active.first
    end
  end
end
