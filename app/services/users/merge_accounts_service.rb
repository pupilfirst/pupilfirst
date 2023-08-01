module Users
  class MergeAccountsService
    def initialize(old_user:, new_user:, student_profile_ids: [])
      @old_user = old_user
      @new_user = new_user
      @student_profile_ids = student_profile_ids.uniq
    end

    def execute
      if @old_user.school != @new_user.school
        raise "Users have to be in the same school"
      end

      User.transaction do
        merge_student_profiles
        merge_coach_profiles
        merge_course_authors
        handle_admin_profile
        merge_community_data
        merge_coach_notes
        merge_markdown_attachments
        merge_issued_certificates
        merge_course_exports
        add_audit_record
        delete_old_account
      end

      Rails.logger.info("Accounts merged successfully!")
    end

    private

    def merge_community_data
      Rails.logger.info("Merging community data...")

      # rubocop:disable Rails/SkipsModelValidations
      TopicSubscription.where(user_id: @old_user).update_all(
        user_id: @new_user.id
      )
      TextVersion.where(user_id: @old_user).update_all(user_id: @new_user.id)
      Post.where(creator_id: @old_user).update_all(creator_id: @new_user.id)
      Post.where(editor_id: @old_user).update_all(editor_id: @new_user.id)
      PostLike.where(user_id: @old_user).update_all(user_id: @new_user.id)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def merge_coach_notes
      Rails.logger.info("Merging coach notes...")

      CoachNote.where(author_id: @old_user).update_all(author_id: @new_user.id) # rubocop:disable Rails/SkipsModelValidations
    end

    def merge_markdown_attachments
      Rails.logger.info("Merging markdown attachments...")
      # rubocop:disable Rails/SkipsModelValidations
      MarkdownAttachment.where(user_id: @old_user).update_all(
        user_id: @new_user.id
      )
      # rubocop:enable Rails/SkipsModelValidations
    end

    def merge_issued_certificates
      Rails.logger.info("Merging issued certificates...")
      # rubocop:disable Rails/SkipsModelValidations
      IssuedCertificate.where(user_id: @old_user).update_all(
        user_id: @new_user.id
      )
      # rubocop:enable Rails/SkipsModelValidations
    end

    def merge_course_exports
      Rails.logger.info("Merging course exports...")

      CourseExport.where(user_id: @old_user).update_all(user_id: @new_user.id) # rubocop:disable Rails/SkipsModelValidations
    end

    def merge_coach_profiles
      old_user_coach = @old_user.faculty

      return if @old_user.faculty.blank?

      Rails.logger.info("Merging coach profiles...")

      new_user_coach =
        @new_user.faculty.presence ||
          Faculty.create!(user: @new_user, category: old_user_coach.category)

      old_user_coach.faculty_cohort_enrollments.each do |enrollment|
        if new_user_coach
             .faculty_cohort_enrollments
             .where(cohort_id: enrollment.cohort_id)
             .present?
          next
        else
          enrollment.update!(faculty_id: new_user_coach.id)
        end
      end

      # rubocop:disable Rails/SkipsModelValidations
      old_user_coach.faculty_student_enrollments.update_all(
        faculty_id: new_user_coach.id
      )

      StartupFeedback.where(faculty_id: old_user_coach).update_all(
        faculty_id: new_user_coach.id
      )

      TimelineEvent.where(evaluator_id: old_user_coach.id).update_all(
        evaluator_id: new_user_coach.id
      )
      # rubocop:enable Rails/SkipsModelValidations
    end

    def merge_course_authors
      return if @old_user.course_authors.blank?

      Rails.logger.info("Merging course author profiles...")

      @old_user.course_authors.each do |course_author|
        if @new_user.course_authors.where(course: course_author.course).present?
          next
        end

        course_author.update!(user_id: @new_user.id)
      end
    end

    def handle_two_student_profiles_for_same_course(course)
      old_student_profile =
        @old_user.students.joins(:course).where(courses: { id: course }).first
      new_student_profile =
        @new_user.students.joins(:course).where(courses: { id: course }).first

      if @student_profile_ids.include?(old_student_profile.id) ^
           @student_profile_ids.include?(new_student_profile.id)
        return if @student_profile_ids.include?(new_student_profile.id)

        old_student_profile.update!(user_id: @new_user.id)
        new_student_profile.destroy!
      else
        raise "A unique student profile ID must be supplied for Course##{course.id}"
      end
    end

    def merge_student_profiles
      return if @old_user.students.blank?

      Rails.logger.info("Merging student profiles...")

      old_user_course_ids = @old_user.courses.pluck(:id)

      new_user_course_ids = @new_user.courses.pluck(:id)

      common_courses = old_user_course_ids & new_user_course_ids

      if common_courses.present? && @student_profile_ids.empty?
        raise "Both users have student profiles in courses with IDs: #{common_courses.join(", ")}. Select one student profile for each course, and pass an array of their IDs using the keyword argument `student_profile_ids`"
      end

      @old_user.students.each do |student|
        course = student.course
        if @new_user
             .students
             .joins(:course)
             .where(courses: { id: course.id })
             .present?
          handle_two_student_profiles_for_same_course(course)
        else
          student.update!(user_id: @new_user.id)
        end
      end
    end

    def handle_admin_profile
      return if @old_user.school_admin.blank?

      Rails.logger.info("Merging school admin...")

      if @new_user.school_admin.present?
        @old_user.school_admin.destroy!
        return
      end

      @old_user.school_admin.update!(user_id: @new_user.id)
    end

    def delete_old_account
      Users::DeleteAccountService.new(@old_user.reload).execute
    end

    def add_audit_record
      AuditRecord.create!(
        school_id: @old_user.school_id,
        audit_type: AuditRecord.audit_types[:merge_user_accounts],
        metadata: {
          user_id: @new_user.id,
          old_account_email: @old_user.email
        }
      )
    end
  end
end
