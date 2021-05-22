module Users
  class MergeAccountsService
    def initialize(old_user, new_user)
      @old_user = old_user
      @new_user = new_user
    end

    def execute
      if @old_user.school != @new_user.school
        raise 'Users has to be in the same school'
      end

      User.transaction do
        merge_community_data
        merge_coach_notes
        merge_markdown_attachments
        merge_issued_certificates
        merge_course_exports
        merge_coach_profiles
        merge_student_profiles
        merge_course_authors
        handle_admin_profile
      end

      Rails.logger.info('Accounts merged successfully!')
    end

    private

    def merge_community_data
      Rails.logger.info('Merging community data...')

      # rubocop:disable Rails/SkipsModelValidations
      TopicSubscription
        .where(user_id: @old_user)
        .update_all(user_id: @new_user.id)
      TextVersion.where(user_id: @old_user).update_all(user_id: @new_user.id)
      Post.where(creator_id: @old_user).update_all(creator_id: @new_user.id)
      Post.where(editor_id: @old_user).update_all(editor_id: @new_user.id)
      PostLike.where(user_id: @old_user).update_all(user_id: @new_user.id)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def merge_coach_notes
      Rails.logger.info('Merging coach notes...')
      CoachNote.where(author_id: @old_user).update_all(author_id: @new_user.id) # rubocop:disable Rails/SkipsModelValidations
    end

    def merge_markdown_attachments
      Rails.logger.info('Merging markdown attachments...')
      MarkdownAttachment
        .where(user_id: @old_user)
        .update_all(user_id: @new_user.id) # rubocop:disable Rails/SkipsModelValidations
    end

    def merge_issued_certificates
      Rails.logger.info('Merging issued certificates...')
      IssuedCertificate
        .where(user_id: @old_user)
        .update_all(user_id: @new_user.id) # rubocop:disable Rails/SkipsModelValidations
    end

    def merge_course_exports
      Rails.logger.info('Merging course exports...')
      CourseExport.where(user_id: @old_user).update_all(user_id: @new_user.id) # rubocop:disable Rails/SkipsModelValidations
    end

    def merge_coach_profiles
      old_user_coach = @old_user.faculty

      return if @old_user.faculty.blank?

      Rails.logger.info('Merging coach profiles...')

      new_user_coach =
        @new_user.faculty.presence ||
          Faculty.create!(user: @new_user, category: old_user_coach.category)

      old_user_coach.faculty_course_enrollments.each do |enrollment|
        if new_user_coach
             .faculty_course_enrollments
             .where(course_id: enrollment.course_id)
             .present?
          next
        else
          enrollment.update!(faculty_id: new_user_coach.id)
        end
      end

      # rubocop:disable Rails/SkipsModelValidations
      old_user_coach.faculty_startup_enrollments.update_all(
        faculty_id: new_user_coach.id
      )

      StartupFeedback
        .where(faculty_id: old_user_coach)
        .update_all(faculty_id: new_user_coach.id)

      TimelineEvent
        .where(evaluator_id: old_user_coach.id)
        .update_all(evaluator_id: new_user_coach.id)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def merge_course_authors
      return if @old_user.course_authors.blank?

      Rails.logger.info('Merging course author profiles...')

      @old_user.course_authors.each do |course_author|
        if @new_user.course_authors.where(course: course_author.course).present?
          next
        end

        user_input =
          prompt_confirmation_message "Do you want to transfer course author rights for #{course_author.course.name} to the new account?\n1 - Yes\n0 - No"

        next if user_input == '0'

        course_author.update!(user_id: @new_user.id)
      end
    end

    def handle_two_student_profiles_for_same_course(course)
      user_input =
        prompt_confirmation_message(
          "Both users have student profiles in course: #{course.name}. Choose the profile that you would like keep. The other would be removed: \n1. #{@new_user.email}\n0. #{@old_user.email}"
        )
      return if user_input == '1'

      old_student_profile =
        @old_user.founders.joins(:course).where(courses: { id: course }).first
      new_student_profile =
        @new_user.founders.joins(:course).where(courses: { id: course }).first

      new_student_profile.update!(user_id: @old_user.id)
      old_student_profile.update!(user_id: @new_user.id)
    end

    def merge_student_profiles
      return if @old_user.founders.blank?

      Rails.logger.info('Merging student profiles...')

      @old_user.founders.each do |founder|
        course = founder.course
        if @new_user
             .founders
             .joins(:course)
             .where(courses: { id: course.id })
             .present?
          handle_two_student_profiles_for_same_course(course)
        else
          founder.update!(user_id: @new_user.id)
        end
      end
    end

    def handle_admin_profile
      return if @old_user.school_admin.blank?

      return if @new_user.school_admin.present?

      Rails.logger.info('Merging school admin...')

      user_input =
        prompt_confirmation_message "Do you want to transfer school admin rights to the new account?\n1: Yes \n0: No"

      return if user_input == '0'

      @old_user.school_admin.update!(user_id: @new_user.id)
    end

    def prompt_confirmation_message(message)
      input = ''
      attempt_counter = 0
      while input != '1' && input != '0'
        question =
          attempt_counter == 0 ? message : 'Retry again with a valid choice'
        Rails.logger.info(question)
        input = gets.chomp!
        attempt_counter += 1
      end
      input
    end

    def delete_old_account
      Users::DeleteAccountService.new(@old_user).execute
    end
  end
end
