module Schools
  class AuthorsController < SchoolsController
    # GET /school/courses/:course_id/authors/new
    def new
      @course = current_school.courses.find(params[:course_id])
      authorize(@course.course_authors.new, policy_class: Schools::CourseAuthorPolicy)
      render 'schools/courses/authors'
    end

    # GET /school/courses/:course_id/authors/:id
    def show
      @course = current_school.courses.find(params[:course_id])
      authorize(@course.course_authors.find(params[:id]), policy_class: Schools::CourseAuthorPolicy)
      render 'schools/courses/authors'
    end
  end
end
