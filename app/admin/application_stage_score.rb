ActiveAdmin.register ApplicationStageScore do
  menu parent: 'Batches', label: 'Application Scores'

  permit_params :application_stage_id, :batch_application_id, :score, :submission_urls
end
