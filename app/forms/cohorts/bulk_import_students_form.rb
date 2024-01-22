require "csv"

module Cohorts
  class BulkImportStudentsForm < Reform::Form
    attr_accessor :current_user

    property :notify_students, virtual: true, validates: { presence: true }
    property :csv,
             virtual: true,
             validates: {
               presence: true,
               file_size: {
                 less_than: 5.megabytes
               }
             }

    validate :soft_limit_student_count
    validate :emails_must_be_valid
    validate :students_must_have_unique_email
    validate :strings_must_not_be_too_long

    def save
      Cohorts::BulkImportStudentsJob.perform_later(
        model,
        csv_rows,
        current_user,
        notify_students == "true"
      )
    end

    def csv_rows
      @csv_rows ||=
        begin
          CSV
            .read(csv, headers: true, col_sep: col_sep(csv))
            .map { |r| r.to_hash }
        end
    end

    def col_sep(csv)
      first_line = File.open(csv, &:readline)
      separators = [",", ";", "\t"]
      separators.find { |separator| first_line.include?(separator) } || ","
    end

    def emails_must_be_valid
      invalid =
        csv_rows.any? do |r|
          r["email"] !~ EmailValidator::REGULAR_EXPRESSION ||
            r["email"].length > 254
        end

      return unless invalid

      errors.add(:base, I18n.t("mutations.create_students.invalid_emails"))
    end

    def students_must_have_unique_email
      return if csv_rows.pluck("email").uniq.count == csv_rows.count

      errors.add(:base, I18n.t("mutations.create_students.unique_emails"))
    end

    def soft_limit_student_count
      return if csv_rows.count <= 1000

      errors.add(
        :base,
        I18n.t("mutations.create_students.thousand_students_limit")
      )
    end

    def valid_string?(string:, max_length:, optional: false)
      return true if string.blank? && optional
      string.length <= max_length
    end

    def strings_must_not_be_too_long
      if csv_rows.all? { |r|
           valid_string?(string: r["name"], max_length: 250) &&
             valid_string?(
               string: r["title"],
               max_length: 250,
               optional: true
             ) &&
             valid_string?(
               string: r["affiliation"],
               max_length: 250,
               optional: true
             ) &&
             valid_string?(
               string: r["team_name"],
               max_length: 50,
               optional: true
             )
         }
        return
      end

      errors.add(:base, I18n.t("mutations.create_students.invalid_strings"))
    end
  end
end
