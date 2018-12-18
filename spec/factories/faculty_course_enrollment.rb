FactoryBot.define do
  factory :faculty_course_enrollment do
    safe_to_create { true }
    faculty
    course
  end
end
