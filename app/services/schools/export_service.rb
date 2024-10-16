module Schools
  class ExportService
    def initialize(export)
      @export = export

      @suffix_hash =
        Digest::SHA256.hexdigest(Time.current.to_s + @school.id.to_s)

      @base_dir = File.join(Dir.tmpdir, "pupilfirst-exports", @suffix_hash)
      FileUtils.mkdir_p(@base_dir)

      @export_rules = ExportRules.new(@school)
    end

    def school
      @school ||= @export.school
    end

    def export
      file_names =
        tables_to_export.map { |table_name| table_to_file(table_name) }

      zipped_file_path = zip_files(file_names)

      update_export(zipped_file_path)
      delete_files(file_names + [zipped_file_path])
    end

    private

    def table_to_file(table_name)
      file_name = "#{table_name}.csv"

      rule = @export_rules.rule(table_name)

      columns = rule[:columns]
      scope = rule[:scope]

      model = table_name.to_s.classify.constantize

      scope.call(model).copy_to(
        File.join(@base_dir, file_name),
        columns: columns
      )

      file_name
    end

    def zip_files(file_names)
      zip_file_path = File.join(@base_dir, "#{school.name}-#{@suffix_hash}.zip")

      Zip::File.open(zip_file_path, create: true) do |zipfile|
        file_names.each do |file_name|
          absolute_file_path = File.join(@base_dir, file_name)

          if File.exist?(absolute_file_path)
            zipfile.add(file_name, absolute_file_path)
          else
            Rails.logger.error(
              "Schools::ExportService: Expected file #{absolute_file_path} was not found."
            )
          end
        end
      end

      zip_file_path
    end

    def update_export(zip_file_path)
      @export.file.attach(
        io: File.open(zip_file_path),
        filename: "#{school.name}-export.zip"
      )

      @export.save!
    end

    def courses
      file_name = "courses.csv"

      school.courses.copy_to(File.join(@base_dir, file_name))

      file_name
    end

    def delete_files(file_names)
      file_names.each do |file_name|
        FileUtils.rm_f(File.join(@base_dir, file_name))
      end
    end
  end

  class ExportRules
    def initialize(school)
      @school = school
    end

    def rule(table_name)
      self.send(:"#{table_name}")
    end

    private

    def tables_to_export
      %i[
        users
        courses
        cohorts
        students
        teams
        faculty
        levels
        target_groups
        targets
        assignments
        timeline_events
        timeline_event_grades
        evaluation_criteria
        certificates
        issued_certificates
        communities
        topics
        posts
        course_exports
        quizzes
        quiz_questions
        answer_options
        coach_notes
        calendar_events
        course_authors
        admin_users
        applicants
        assignments_evaluation_criteria
        assignments_prerequisite_assignments
        audit_records
        calendar_cohorts
        calendars
        community_course_connections
        content_blocks
        course_categories
        course_exports_cohorts
        course_ratings
        courses_course_categories
        faculty_cohort_enrollments
        faculty_student_enrollments
        moderation_reports
        organisation_admins
        organisations
        page_reads
        post_likes
        reactions
        school_admins
        school_links
        school_strings
        standings
        startup_feedback
        submission_comments
        submission_reports
        timeline_event_owners
        topic_categories
        topic_subscriptions
        user_standings
      ]
    end

    def courses
      { columns: nil, scope: ->(_) { @school.courses } }
    end

    def users
      excluded_columns = %i[
        api_token_digest
        confirmed_at
        current_sign_in_at
        encrypted_password
        last_sign_in_at
        login_token
        login_token_digest
        login_token_generated_at
        remember_created_at
        remember_token
        reset_password_sent_at
        reset_password_token
        sign_in_count
        sign_out_at_next_request
        webpush_subscription
      ]

      {
        columns: User.column_names.map(&:to_sym) - excluded_columns,
        scope: ->(_) { @school.users }
      }
    end
  end
end
