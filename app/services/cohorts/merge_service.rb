module Cohorts
  class MergeService
    def initialize(cohort)
      @cohort = cohort
    end

    def merge_into(other_cohort)
      if other_cohort.course_id != @cohort.course_id
        raise "Cannot merge cohort ##{@cohort.id} into cohort ##{other_cohort.id}"
      end

      Cohort.transaction do
        @cohort.teams.update_all(cohort_id: other_cohort.id) # rubocop:disable Rails/SkipsModelValidations
        @cohort.students.update_all(cohort_id: other_cohort.id) # rubocop:disable Rails/SkipsModelValidations

        coaches_in_other_cohort = other_cohort.faculty.pluck(:id)
        @cohort.faculty_cohort_enrollments.each do |enrollment|
          unless coaches_in_other_cohort.include?(enrollment.faculty_id)
            other_cohort.faculty_cohort_enrollments.create!(
              cohort_id: other_cohort.id,
              faculty_id: enrollment.faculty_id
            )
          end
        end
        @cohort.faculty_cohort_enrollments.destroy_all
        @cohort.reload.destroy!
      end

      other_cohort
    end
  end
end
