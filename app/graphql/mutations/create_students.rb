module Mutations
  class CreateStudents < ApplicationQuery
    include QueryAuthorizeSchoolAdmin

    argument :cohort_id, ID, required: true
    argument :students, [Types::StudentEnrollmentInputType], required: true
    argument :notify_students, Boolean, required: true

    description 'Add one or more students to a course'

    field :student_ids, [ID], null: true

    def resolve(_params)
      student_ids = create_students
      { student_ids: student_ids }
    end

    class ValidateCreateStudentData < GraphQL::Schema::Validator
      include ValidatorCombinable

      def validate(_object, _context, value)
        @cohort = Cohort.find_by(id: value[:cohort_id])
        @students = value[:students]

        combine(
          students_must_have_unique_email,
          strings_must_not_be_too_long,
          emails_must_be_valid,
          soft_limit_student_count
        )
      end

      def valid_string?(string:, max_length:, optional: false)
        return true if string.blank? && optional
        string.length <= max_length
      end

      def strings_must_not_be_too_long
        if @students.all? do |s|
             valid_string?(string: s.name, max_length: 250) &&
               valid_string?(
                 string: s.title,
                 max_length: 250,
                 optional: true
               ) &&
               valid_string?(
                 string: s.affiliation,
                 max_length: 250,
                 optional: true
               ) &&
               valid_string?(
                 string: s.team_name,
                 max_length: 50,
                 optional: true
               )
           end
          return
        end

        'One or more of the entries have invalid strings'
      end

      def emails_must_be_valid
        invalid =
          @students.any? do |s|
            s.email !~ EmailValidator::REGULAR_EXPRESSION ||
              s.email.length > 254
          end

        return unless invalid

        'One or more of the entries have an invalid email address'
      end

      def soft_limit_student_count
        if @cohort.blank? || @cohort.course.blank? ||
             @cohort.course.founders.count < 100_000
          return
        end

        "You've hit the soft-limit for number of students in this course"
      end

      def students_must_have_unique_email
        if @students.map { |student| student.email.downcase }.uniq.count ==
             @students.count
          return
        end

        'Email addresses must be unique'
      end
    end

    validates ValidateCreateStudentData => {}

    private

    def create_students
      ::Cohorts::AddStudentsService
        .new(cohort, notify: @params[:notify_students])
        .add(@params[:students])
    end

    def resource_school
      course&.school
    end

    def course
      @course ||= cohort&.course
    end

    def cohort
      @cohort ||= Cohort.find_by(id: @params[:cohort_id])
    end

    def allow_token_auth?
      true
    end
  end
end
