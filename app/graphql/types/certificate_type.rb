module Types
  class CertificateType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :course, Types::CourseType, null: false
    field :qr_corner, String, null: false
    field :qr_scale, Integer, null: false
    field :name_offset_top, Integer, null: false
    field :font_size, Integer, null: false
    field :margin, Integer, null: false
    field :active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def course
      BatchLoader::GraphQL
        .for(object.course_id)
        .batch do |course_ids, loader|
          Course
            .where(id: course_ids)
            .each { |course| loader.call(course.id, course) }
        end
    end
  end
end
