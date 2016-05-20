ActiveAdmin.register ApplicationStageScore do
  menu parent: 'Batches', label: 'Application Scores'

  permit_params :application_stage_id, :batch_application_id, :score, :submission_urls

  index do
    selectable_column

    column :batch_application do |application_stage_score|
      application = application_stage_score.batch_application
      link_to application.display_name, admin_batch_application_path(application)
    end

    column :application_stage

    column :submissions do |application_stage_score|
      if application_stage_score.submission_urls.present?
        ul do
          application_stage_score.submission_urls.each do |key, value|
            li do
              link_to key, value
            end
          end
        end
      end
    end

    column :score

    actions
  end
end
