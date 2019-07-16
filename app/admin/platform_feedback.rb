ActiveAdmin.register PlatformFeedback do
  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard', label: 'Platform Feedback'

  permit_params :founder_id, :feedback_type, :description, :promoter_score, :notes

  filter :feedback_type
  filter :created_at
  filter :notes

  index do
    selectable_column

    column :feedback_type
    column :founder

    column :description do |feedback|
      truncate(feedback.description, length: 200)
    end

    column 'PS', :promoter_score

    actions
  end

  show do
    attributes_table do
      row :feedback_type
      row :founder
      row :description
      row :promoter_score
      row :notes
      row :created_at
    end
  end
end
