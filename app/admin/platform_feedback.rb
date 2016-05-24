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

  show do |feedback|
    attributes_table do
      row :feedback_type
      row :founder
      row :description
      row :attachment do
        if feedback.attachment.present?
          link_to feedback.attachment.url, target: '_blank' do
            image_tag feedback.attachment.url, width: '200px'
          end
        end
      end
      row :promoter_score
      row :created_at
    end
  end
end
