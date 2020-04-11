module Types
  class CourseExportType < Types::BaseObject
    field :id, ID, null: false
    field :export_type, Types::ExportType, null: false
    field :created_at, String, null: false
    field :tags, [String], null: false
    field :reviewedOnly, Boolean, null: false

    def tags
      object.tag_list
    end
  end
end
