class CoachMailer < SchoolMailer
  def course_enrollment(coach, course)
    @school = course.school
    @course = course
    @coach = coach

    simple_roadie_mail(coach.email, "You have been added as a coach in #{@course.name}")
  end
end
