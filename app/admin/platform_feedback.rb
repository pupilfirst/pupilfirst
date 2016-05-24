ActiveAdmin.register PlatformFeedback do
  menu parent: 'Dashboard', label: 'Platform Feedback'

  permit_params :founder_id, :feedback_type, :description, :attachment, :promoter_score

  index do
    selectable_column

    column :feedback_type
    column :founder
    column :description do |feedback|
      truncate(feedback.description, length: 200)
    end
    column :karma_point do |feedback|
      if feedback.karma_point.present?
        link_to feedback.karma_point.points, admin_karma_point_path(feedback.karma_point)
      else
        link_to 'Assign Karma Points', edit_admin_platform_feedback_path(feedback)
      end
    end

    actions
  end
end
