FactoryBot.define do
  factory :faculty_founder_enrollment do
    faculty
    founder
  end

  trait :with_cohort_enrollment do
    after(:create) do |enrollment|
      cohort = enrollment.founder.cohort
      coach = enrollment.faculty

      if FacultyCohortEnrollment.where(faculty: coach, cohort: cohort).blank?
        create :faculty_cohort_enrollment, faculty: coach, cohort: cohort
      end
    end
  end
end
