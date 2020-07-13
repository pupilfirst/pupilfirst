module Schools
  class DeleteService
    def initialize(school)
      @school = school
    end

    def execute
      School.transaction do
        delete_school_strings
        delete_school_links
        delete_school_admins
        delete_courses
        delete_communities
        delete_taggings
        delete_markdown_attachments
        delete_domains
        delete_audit_records
        delete_users

        @school.reload.destroy!
      end
    end

    alias perform execute

    private

    def delete_school_strings
      @school.school_strings.delete_all
    end

    def delete_school_links
      @school.school_links.delete_all
    end

    def delete_school_admins
      @school.school_admins.delete_all
    end

    def delete_courses
      @school.courses.each do |course|
        ::Courses::DeleteService.new(course).execute
      end
    end

    def delete_communities
      @school.communities.each do |community|
        ::Communities::DeleteService.new(community).execute
      end
    end

    def delete_taggings
      ActsAsTaggableOn::Tagging.where(taggable_type: 'School').where(taggable_id: @school.id).delete_all
    end

    def delete_markdown_attachments
      @school.markdown_attachments.each(&:destroy!)
    end

    def delete_domains
      @school.domains.delete_all
    end

    def delete_audit_records
      @school.audit_records.delete_all
    end

    def delete_users
      Faculty.joins(user: :school).where(schools: { id: @school.id }).delete_all
      @school.users.each(&:destroy!)
    end
  end
end
