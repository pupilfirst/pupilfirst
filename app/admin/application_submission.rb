ActiveAdmin.register ApplicationSubmission do
  menu parent: 'Batches'

  permit_params :application_stage_id, :batch_application_id, :score, :notes, :file,
    application_submission_urls_attributes: [:id, :name, :url, :score, :_destroy]

  filter :batch_application_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'Batch'
  filter :batch_application
  filter :application_stage
  filter :score
  filter :notes

  batch_action :promote, confirm: 'Are you sure?' do |ids|
    promoted = 0

    ApplicationSubmission.where(id: ids).each do |application_submission|
      batch_application = application_submission.batch_application

      if batch_application.promotable? && application_submission.application_stage == batch_application.application_stage
        batch_application.promote!
        promoted += 1
      end
    end

    flash[:success] = "#{promoted} #{'application'.pluralize(promoted)} successfully promoted!"

    redirect_to collection_path
  end

  index do
    selectable_column

    column :batch_application do |application_submission|
      application = application_submission.batch_application
      link_to application.display_name, admin_batch_application_path(application)
    end

    column :application_stage

    column :file do |application_submission|
      if application_submission.file.present?
        link_to application_submission.file_name, application_submission.file.url
      end
    end

    column 'Submitted Links' do |application_submission|
      if application_submission.application_submission_urls.present?
        ul do
          application_submission.application_submission_urls.each do |entry|
            li do
              span do
                link_to entry.name, entry.url
              end

              span(" (#{entry.score})") if entry.score.present?
            end
          end
        end
      end
    end

    column :score

    actions do |application_submission|
      application = application_submission.batch_application

      if application.promotable? && application_submission.application_stage == application.application_stage
        span do
          link_to 'Promote', promote_admin_batch_application_path(application), method: :post, class: 'member_link'
        end
      end
    end
  end

  action_item :promote, only: :show do
    application = application_submission.batch_application

    if application.promotable? && application_submission.application_stage == application.application_stage
      link_to('Promote application to next stage', promote_admin_batch_application_path(application), method: :post)
    end
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

                span " (#{entry.score})" if entry.score.present?
              end
            end
          end
        end
      end

      row :file do |application_submission|
        if application_submission.file.present?
          link_to application_submission.file_name, application_submission.file.url
        end
      end

      row :score

      row :notes do |application_submission|
        notes = application_submission.notes
        Kramdown::Document.new(notes).to_html.html_safe if notes.present?
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
      f.input :file
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
