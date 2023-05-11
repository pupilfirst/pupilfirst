module Schools
  class ArchiveCoachService
    def initialize(faculty, archive)
      @faculty = faculty
      @should_archive = archive == "true" ? true : false
    end

    def execute
      if !@faculty.exited? && @should_archive
        @faculty.exited = true
        @faculty.save!
        FacultyCohortEnrollment.where(faculty: @faculty).destroy_all
        FacultyFounderEnrollment.where(faculty: @faculty).destroy_all
      elsif @faculty.exited? && !@should_archive
        @faculty.exited = false # unarchive
        @faculty.save!
      end
    end
  end
end
