module Courses
  class BulkImportStudentsForm < Reform::Form
    property :csv, virtual: true, validates: { presence: true, file_size: { less_than: 5.megabytes } }

    def save
      Course.transaction do
        text = File.read(
          csv,
          {encoding: 'UTF-8'}
        )
        Courses::OnboardService.new(model, text).execute
      end
    end
  end
end
