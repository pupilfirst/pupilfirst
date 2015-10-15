ActiveAdmin.register ConnectRequest do
  permit_params :connect_slot_id, :startup_id, :questions, :meeting_link, :status

  menu parent: 'Faculty'

  index do
    selectable_column

    column :connect_slot
    column :startup, label: 'Product'
    column :status
    column :created_at

    actions
  end

  member_action :confirm, method: :post do
    connect_request = ConnectRequest.find params[:id]
    connect_request.confirm!

    flash[:success] = "Confirmed request from #{connect_request.startup.display_name}."
    redirect_to admin_connect_request_path(connect_request)
  end

  show do
    attributes_table do
      row :id
      row :connect_slot
      row :startup, label: 'Product'

      row :questions do |connect_request|
        simple_format connect_request.questions
      end

      row :status do |connect_request|
        span class: 'connect-request-status' do
          connect_request.status
        end
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Connect Request Details' do
      f.input :connect_slot,
        collection: (resource.persisted? ? ConnectSlot.available(optional_id: resource.connect_slot.id) : ConnectSlot.available).includes(:faculty),
        required: true
      f.input :startup, label: 'Product', collection: Startup.batched.approved, required: true
      f.input :questions
      f.input :meeting_link
      f.input :status, as: :select, collection: ConnectRequest.valid_statuses, include_blank: false
    end

    f.actions
  end
end
