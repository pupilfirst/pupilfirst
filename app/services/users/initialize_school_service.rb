module Users
  class InitializeSchoolService
    def initialize(user, course)
      @user = user
      @course = course
    end

    def execute
      User.transaction do
        new_course =
          Courses::CloneService.new(@course).clone(@course.name, @user.school)
        cohort =
          Cohort.create!(
            name: "Purple (Auto-generated)",
            description:
              "Auto generated cohort for active students in #{new_course.name}",
            course_id: new_course.id
          )
        new_course.update!(default_cohort_id: cohort.id)
        create_and_assign_coach(new_course, cohort)
        Student.create!(user: @user, cohort: cohort)
        create_community(new_course)
      end
    end

    alias perform execute

    private

    def create_and_assign_coach(course, cohort)
      coach =
        Faculty.create!(
          user: @user,
          school: @user.school,
          category: Faculty::CATEGORY_VISITING_COACHES
        )
      Cohorts::ManageReviewerService.new(course, [cohort]).assign(coach)
    end

    def create_community(course)
      community =
        @user.school.communities.create!(name: "Demo", target_linkable: true)
      CommunityCourseConnection.create!(course: course, community: community)
    end
  end
end
