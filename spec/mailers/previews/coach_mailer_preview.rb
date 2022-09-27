class CoachMailerPreview < ActionMailer::Preview
  def course_enrollment
    course = Course.first
    coach = course.faculty.last || Faculty.first

    CoachMailer.course_enrollment(coach, course)
  end
end
