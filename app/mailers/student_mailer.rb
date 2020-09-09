class StudentMailer < SchoolMailer
  def enrollment(student)
    @school = student.course.school
    @course = student.course
    @student = student

    simple_roadie_mail(@student.email, "You have been added as a student in #{@school.name}")
  end
end
