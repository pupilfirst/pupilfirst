module Users
  class InitializeSchoolService
    def initialize(user, course)
      @user = user
      @course = course
    end

    def execute
      User.transaction do
        new_course = Courses::CloneService.new(@course).clone(@course.name, @user.school)
        create_and_assign_coach(new_course)
        create_student(new_course)
        create_community(new_course)
      end
    end

    alias perform execute

    private

    def create_and_assign_coach(course)
      coach = Faculty.create!(
        user: @user,
        school: @user.school,
        category: Faculty::CATEGORY_VISITING_COACHES
      )
      Courses::AssignReviewerService.new(course, notify: false).assign(coach)
    end

    def create_student(course)
      team = Startup.create!(
        name: @user.name,
        level: course.levels.find_by(number: 1)
      )
      Founder.create!(user: @user, startup: team)
    end

    def create_community(course)
      community = @user.school.communities.create!(name: "Demo", target_linkable: true)
      CommunityCourseConnection.create!(course: course, community: community)
    end
  end
end
