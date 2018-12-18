FactoryBot.define do
  factory :faculty_startup_enrollment do
    safe_to_create { true }
    faculty
    startup
  end
end
