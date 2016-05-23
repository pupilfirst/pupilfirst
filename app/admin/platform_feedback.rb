ActiveAdmin.register PlatformFeedback do
  menu parent: 'Dashboard', label: 'Platform Feedback'

  permit_params :founder_id, :feedback_type, :description, :attachment, :promoter_score
end
