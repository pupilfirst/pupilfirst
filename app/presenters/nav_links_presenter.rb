class NavLinksPresenter < ApplicationPresenter
  def selectable_student_profiles
    @selectable_student_profiles ||= begin
      if view.current_school.blank? || view.current_founder.blank?
        Founder.none
      else
        view.current_user.founders
          .not_exited
          .where.not(id: view.current_founder.id)
          .joins(:school).where(schools: { id: view.current_school })
      end
    end
  end
end
