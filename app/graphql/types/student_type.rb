module Types
  class StudentType < Types::BaseObject
    field :id, ID, null: false
    field :taggings, [String], null: false
    field :issued_certificates, [Types::IssuedCertificateType], null: false
    field :dropped_out_at, GraphQL::Types::ISO8601DateTime, null: true
    field :user, Types::UserType, null: false
    field :personal_coaches, [Types::UserProxyType], null: false
    field :cohort, Types::CohortType, null: false
    field :course, Types::CourseType, null: false
    field :github_repository, String, null: true

    def issued_certificates
      # rubocop:disable Lint/UselessAssignment
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch(default_value: []) do |user_ids, loader|
          IssuedCertificate
            .where(user_id: user_ids, certificate: object.course.certificates)
            .order("created_at DESC")
            .each do |issued_certificate|
              loader.call(issued_certificate.user_id) do |memo|
                memo |= [issued_certificate]
              end
            end
        end
      # rubocop:enable Lint/UselessAssignment
    end

    def cohort
      BatchLoader::GraphQL
        .for(object.cohort_id)
        .batch do |cohort_ids, loader|
          Cohort
            .where(id: cohort_ids)
            .each { |cohort| loader.call(cohort.id, cohort) }
        end
    end

    def course
      BatchLoader::GraphQL
        .for(object.cohort_id)
        .batch do |cohort_ids, loader|
          Cohort
            .joins(:course)
            .where(id: cohort_ids)
            .each { |cohort| loader.call(cohort.id, cohort.course) }
        end
    end

    def user
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User.where(id: user_ids).each { |user| loader.call(user.id, user) }
        end
    end

    def taggings
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |student_ids, loader|
          tags =
            Student
              .joins(taggings: :tag)
              .where(id: student_ids)
              .distinct("tags.name")
              .select(:id, "array_agg(tags.name)")
              .group(:id)
              .reduce({}) do |acc, user|
                acc[user.id] = user.array_agg
                acc
              end
          student_ids.each { |id| loader.call(id, tags.fetch(id, [])) }
        end
    end

    def personal_coaches
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |student_ids, loader|
          FacultyStudentEnrollment
            .joins(:faculty)
            .where(student_id: student_ids)
            .each do |enrollment|
              loader.call(enrollment.student_id) do |memo|
                memo |= [enrollment.faculty].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end
  end
end
