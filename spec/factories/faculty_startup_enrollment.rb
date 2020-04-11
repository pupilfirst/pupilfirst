FactoryBot.define do
  factory :faculty_startup_enrollment do
    safe_to_create { true }
    faculty
    startup
  end

  trait :with_course_enrollment do
    after(:create) do |enrollment|
      course = enrollment.startup.course
      coach = enrollment.faculty

      if FacultyCourseEnrollment.where(faculty: coach, course: course).blank?
        create :faculty_course_enrollment, faculty: coach, course: course
      end
    end
  end
end
