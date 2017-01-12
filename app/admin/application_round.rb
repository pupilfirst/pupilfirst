ActiveAdmin.register ApplicationRound do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :batch_id, :number, :campaign_start_at, :target_application_count,
    round_stages_attributes: [:id, :application_stage_id, :starts_at, :ends_at, :_destroy]

  filter :batch
  filter :number
  filter :created_atg

  controller do
    def scoped_collection
      # https://github.com/activeadmin/activeadmin/issues/659#issuecomment-224429833
      ApplicationRound.all.order('batch_id DESC, number ASC')
    end
  end

  config.sort_order = ''

  index do
    selectable_column

    column :batch
    column :number

    column :active_stages do |batch|
      batch.round_stages.select(&:active?).map { |active_round_stage| active_round_stage.application_stage.name }.join ', '
    end

    actions
  end

  show do |application_round|
    attributes_table do
      row :batch
      row :number
      row :campaign_start_at
      row :target_application_count
    end

    panel 'Round Stages' do
      application_round.round_stages.joins(:application_stage).order('application_stages.number').each do |round_stage|
        attributes_table_for round_stage do
          row :application_stage
          row :starts_at
          row :ends_at
        end
      end
    end

    panel 'Technical details' do
      attributes_table_for application_round do
        row :id
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :batch, collection: Batch.order('created_at DESC')
      f.input :number

      f.input :campaign_start_at,
        as: :string,
        input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O' } },
        placeholder: 'YYYY-MM-DD HH:MM:SS'

      f.input :target_application_count
    end

    f.inputs 'Stage Dates' do
      f.has_many :round_stages, heading: false, allow_destroy: true, new_record: 'Add Stage' do |s|
        s.input :application_stage, collection: ApplicationStage.order('number ASC')
        s.input :starts_at, as: :string, input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O' } }, placeholder: 'YYYY-MM-DD HH:MM:SS'
        s.input :ends_at, as: :string, input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O', 'allow-times': '["23:59"]', 'default-time': '23:59' } }, placeholder: 'YYYY-MM-DD HH:MM:SS'
      end
    end

    f.actions
  end
end
