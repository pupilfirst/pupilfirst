FactoryBot.define do
  factory :faculty_student_enrollment do
    faculty
    founder
  end

  trait :with_course_enrollment do
    after(:create) do |enrollment|
      course = enrollment.cohort.course
      coach = enrollment.faculty

      if FacultyCourseEnrollment.where(faculty: coach, course: course).blank?
        create :faculty_course_enrollment, faculty: coach, course: course
      end
    end
  end
end
