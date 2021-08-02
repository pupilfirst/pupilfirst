require 'csv'

module Courses
  class BulkImportStudentsForm < Reform::Form
    attr_accessor :current_user

    property :notify_students, virtual: true, validates: { presence: true }
    property :csv, virtual: true, validates: { presence: true, file_size: { less_than: 5.megabytes } }

    validate :soft_limit_student_count
    validate :emails_must_be_valid
    validate :students_must_have_unique_email
    validate :strings_must_not_be_too_long

    def save
      Courses::BulkImportStudentsJob.perform_later(model, csv_rows, current_user, notify_students == 'true')
    end

    def csv_rows
      @csv_rows ||= begin
        text = File.read(
          csv,
          { encoding: 'UTF-8' }
        )
        CSV.parse(text, headers: true).map { |r| r.to_hash }
      end
    end

    def emails_must_be_valid
      invalid = csv_rows.any? do |r|
        r['email'] !~ EmailValidator::REGULAR_EXPRESSION || r['email'].length > 254
      end

      return unless invalid

      errors[:base] << 'One or more entries have an invalid email address'
    end

    def students_must_have_unique_email
      return if csv_rows.map { |r| r['email'] }.uniq.count == csv_rows.count

      errors[:base] << 'Email addresses must be unique'
    end

    def soft_limit_student_count
      return if csv_rows.count <= 1000

      errors[:base] << "You can only onboard 1000 students at a time"
    end

    def valid_string?(string:, max_length:, optional: false)
      return true if string.blank? && optional
      string.length <= max_length
    end

    def strings_must_not_be_too_long
      return if csv_rows.all? do |r|
        valid_string?(string: r['name'], max_length: 250) &&
          valid_string?(string: r['title'], max_length: 250, optional: true) &&
          valid_string?(string: r['affiliation'], max_length: 250, optional: true) &&
          valid_string?(string: r['team_name'], max_length: 50, optional: true)
      end

      errors[:base] << 'One or more entries have invalid strings'
    end
  end
end
