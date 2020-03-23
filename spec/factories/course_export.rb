FactoryBot.define do
  factory :course_export do
    user
    course

    trait :students do
      export_type { CourseExport::EXPORT_TYPE_STUDENTS }
    end

    trait :teams do
      export_type { CourseExport::EXPORT_TYPE_TEAMS }
    end
  end
end
