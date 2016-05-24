ActiveAdmin.register ApplicationSubmission do
  menu parent: 'Batches'

  permit_params :application_stage_id, :batch_application_id, :score, :notes,
    application_submission_urls_attributes: [:id, :name, :url, :score, :_destroy]

  filter :batch_application_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'Batch'
  filter :batch_application
  filter :application_stage
  filter :score
  filter :notes

  index do
    selectable_column

    column :batch_application do |application_submission|
      application = application_submission.batch_application
      link_to application.display_name, admin_batch_application_path(application)
    end

    column :application_stage

    column 'Submitted Links' do |application_submission|
      if application_submission.application_submission_urls.present?
        ul do
          application_submission.application_submission_urls.each do |entry|
            li do
              span do
                link_to "#{entry.name}", entry.url
              end

              if entry.score.present?
                span " (#{entry.score})"
              end
            end
          end
        end
      end
    end

    column :score

    actions
  end

  show do
    attributes_table do
      row :application_stage

      row :batch_application do |application_submission|
        application = application_submission.batch_application
        link_to application.display_name, admin_batch_application_path(application)
      end

      row 'Submitted Links' do |application_submission|
        if application_submission.application_submission_urls.present?
          ul do
            application_submission.application_submission_urls.each do |entry|
              li do
                span do
                  strong entry.name + ': '
                  span { link_to entry.url, entry.url }
                end

                if entry.score.present?
                  span " (#{entry.score})"
                end
              end
            end
          end
        end
      end

      row :score

      row :notes do |application_submission|
        notes = application_submission.notes

        if notes.present?
          Kramdown::Document.new(notes).to_html.html_safe
        end
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :application_stage
      f.input :batch_application
      f.input :score
      f.input :notes, placeholder: 'Use markdown to format.'
    end

    f.inputs 'Submitted URLs' do
      f.has_many :application_submission_urls, new_record: 'Add URL', allow_destroy: true, heading: false do |t|
        t.input :name
        t.input :url
        t.input :score
      end
    end

    f.actions
  end
end
