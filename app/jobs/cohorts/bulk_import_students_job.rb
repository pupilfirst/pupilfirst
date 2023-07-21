module Cohorts
  class BulkImportStudentsJob < ApplicationJob
    require "csv"

    queue_as :low_priority

    def perform(cohort, csv_rows, user, notify_students)
      student_ids =
        ::Cohorts::OnboardService.new(
          cohort,
          csv_rows,
          notify_students: notify_students
        ).execute

      report_params = {
        students_added: student_ids.count,
        students_requested: csv_rows.count
      }

      SchoolAdminMailer.students_bulk_import_complete(
        user,
        cohort.course,
        report_params,
        report_attachment(csv_rows, student_ids)
      ).deliver_later
    end

    private

    def report_attachment(csv_rows, student_ids)
      return if csv_rows.count == student_ids.count

      applicable_emails =
        csv_rows.map { |row| row["email"].downcase } -
          Student
            .where(id: student_ids)
            .joins(:user)
            .pluck(:email)
            .map(&:downcase)

      headers = ["Sl. No", "Email"]

      csv_data =
        CSV.generate(headers: true) do |csv|
          csv << headers
          applicable_emails.each_with_index do |email, index|
            csv << [index + 1, email]
          end
        end

      { mime_type: "text/csv", content: csv_data }
    end
  end
end
