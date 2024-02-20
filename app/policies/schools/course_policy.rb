module Schools
  class CoursePolicy < ApplicationPolicy
    def index?
      # Can be shown to all school admins.
      user&.school_admin.present? && user.school == current_school
    end

    def authors?
      record.school == current_school && !record.archived? && index?
    end

    def show?
      record.school == current_school && index?
    end

    alias new? index?
    alias details? show?
    alias images? show?
    alias actions? show?
    alias attach_images? show?
    alias delete_coach_enrollment? authors?
    alias update_coach_enrollments? authors?
    alias students? authors?
    alias applicants? authors?
    alias exports? authors?
    alias certificates? authors?
    alias create_certificate? authors?
    alias calendars? index?
    alias calendar_events? index?
    alias calendar_month_data? index?

    def curriculum?
      return false if user.blank?

      # All school admins can manage course curriculum.
      return true if authors?

      # All course authors can manage course curriculum.
      user.course_authors.where(course: record).present?
    end

    alias evaluation_criteria? curriculum?
    alias assignments? curriculum?
    class Scope < Scope
      def resolve
        current_school.courses
      end
    end
  end
end
