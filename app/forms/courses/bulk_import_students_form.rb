require 'csv'

module Courses
  class BulkImportStudentsForm < Reform::Form
    property :csv, virtual: true, validates: { presence: true, file_size: { less_than: 5.megabytes } }

    validate :soft_limit_student_count
    validate :emails_must_be_valid
    validate :students_must_have_unique_email

    def save
      Course.transaction do
        Courses::OnboardService.new(model, csv_rows).execute
      end
    end

    def csv_rows
      @csv_rows ||= begin
        text = File.read(
          csv,
          { encoding: 'UTF-8' }
        )
        CSV.parse(text, headers: true)
      end
    end

    def emails_must_be_valid
      invalid = csv_rows.any? do |r|
        r['email'] !~ EmailValidator::REGULAR_EXPRESSION || r['email'].length > 254
      end

      return unless invalid

      errors[:base] << 'One or more of the entries have an invalid email address'
    end

    def students_must_have_unique_email
      return if csv_rows.map { |r| r['email'] }.uniq.count == csv_rows.count

      errors[:base] << 'Email addresses must be unique'
    end

    def soft_limit_student_count
      return if csv_rows.count < 1000

      errors[:base] << "You can only onboard less than 1000 students at a time"
    end
  end
end
