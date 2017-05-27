ActiveAdmin.register ApplicationRound do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :batch_id, :number, :campaign_start_at, :target_application_count,
    round_stages_attributes: %i[id application_stage_id starts_at ends_at _destroy]

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

  member_action :sweep_in_applications do
    @application_round = ApplicationRound.find(params[:id])
    render 'sweep_in_applications'
  end

  action_item :sweep_in_applications, only: :show, if: proc { resource&.initial_stage? } do
    link_to('Sweep in Applications', sweep_in_applications_admin_application_round_path(ApplicationRound.find(params[:id])))
  end

  member_action :create_sweep_job, method: :post do
    sweep_unpaid = params[:sweep_in_applications][:sweep_unpaid] == '1'
    sweep_application_round_ids = (params[:sweep_in_applications][:source_application_round_ids] - ['']).map(&:to_i)
    skip_payment = params.dig(:sweep_in_applications, :skip_payment) == '1'
    application_round = ApplicationRound.find(params[:id])

    if application_round.initial_stage?
      BatchSweepJob.perform_later(
        application_round.id,
        sweep_unpaid,
        sweep_application_round_ids,
        current_admin_user.email,
        skip_payment: skip_payment
      )

      flash[:success] = 'Sweep Job has been created. You will be sent an email with the results when it is complete.'
    else
      flash[:error] = "Did not initiate sweep. #{application_round.display_name} is not in initial stage."
    end

    redirect_to admin_application_round_path(application_round)
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
