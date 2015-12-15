ActiveAdmin.register ConnectRequest do
  permit_params :connect_slot_id, :startup_id, :questions, :meeting_link, :status

  menu parent: 'Faculty'

  scope :all, default: true
  scope :confirmed
  scope :requested

  controller do
    def scoped_collection
      super.includes :connect_slot
    end
  end

  index do
    selectable_column

    column :connect_slot
    column :startup, label: 'Product'
    column :status
    column :slot_date, sortable: 'connect_slots.slot_at' do |connect_request|
      connect_request.connect_slot.slot_at.in_time_zone('Asia/Calcutta').strftime('%b %-d, %-I:%M %p')
    end

    actions
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

      row :meeting_link
      row :confirmed_at
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
