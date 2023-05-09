module Schools
  class ArchiveCoachService
    def initialize(faculty)
      @faculty = faculty
    end

    def execute
      if !@faculty.archived_at?
        @faculty.archived_at = Time.zone.now
        @faculty.save!
        FacultyCohortEnrollment.where(faculty: @faculty).destroy_all
        FacultyFounderEnrollment.where(faculty: @faculty).destroy_all
      end
    end
  end
end
