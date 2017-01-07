ActiveAdmin.register ApplicationRound do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :batch_id, :number, :starts_at, :ends_at, :campaign_start_at, :target_application_count

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
    column :starts_at
    column :ends_at

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :batch, collection: Batch.order('created_at DESC')
      f.input :number

      f.input :starts_at,
        as: :string,
        input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O' } },
        placeholder: 'YYYY-MM-DD HH:MM:SS'

      f.input :ends_at,
        as: :string,
        input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O', 'allow-times': '["23:59"]', 'default-time': '23:59' } },
        placeholder: 'YYYY-MM-DD HH:MM:SS'

      f.input :campaign_start_at,
        as: :string,
        input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O' } },
        placeholder: 'YYYY-MM-DD HH:MM:SS'

      f.input :target_application_count
    end

    f.actions
  end
end
