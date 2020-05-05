class CoachNotesResolver < ApplicationQuery
  property :student_id

  def coach_notes
    CoachNote.not_archived.where(student_id: student_id).includes(author: { avatar_attachment: :blob }).order('created_at DESC').limit(20)
  end

  def authorized?
    return false if current_user.blank?

    return false if student.blank?

    current_user.faculty.reviewable_courses.where(id: student.course).exists?
  end

  def student
    @student ||= Founder.where(id: student_id).first
  end
end
