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

  action_item :record_feedback, only: :show do
    link_to 'Record Feedback', new_admin_startup_feedback_path(startup_feedback: { startup_id: connect_request.startup.id })
  end

  index do
    selectable_column

    column :connect_slot
    column :startup, label: 'Product'
    column :status
    column :slot_date, sortable: 'connect_slots.slot_at' do |connect_request|
      connect_request.connect_slot.slot_at.in_time_zone('Asia/Calcutta').strftime('%b %-d, %-I:%M %p')
    end

    column :rating_of_faculty do |connect_request|
      if connect_request.rating_of_faculty.present?
        connect_request.rating_of_faculty.times do
          i class: 'fa fa-star'
        end
      end
    end

    column :rating_of_team do |connect_request|
      if connect_request.rating_of_team.present?
        connect_request.rating_of_team.times do
          i class: 'fa fa-star'
        end
      end
    end

    actions do |connect_request|
      span do
        link_to 'Record Feedback', new_admin_startup_feedback_path(startup_feedback: { startup_id: connect_request.startup.id }), class: 'member_link'
      end
    end
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

      row :rating_of_faculty do |connect_request|
        if connect_request.rating_of_faculty.present?
          connect_request.rating_of_faculty.times do
            i class: 'fa fa-star'
          end
        end
      end

      row :rating_of_team do |connect_request|
        if connect_request.rating_of_team.present?
          connect_request.rating_of_team.times do
            i class: 'fa fa-star'
          end
        end
      end

      row :confirmed_at
      row :feedback_mails_sent_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Connect Request Details' do
      f.input :connect_slot,
        collection: (resource.persisted? ? ConnectSlot.available(optional_id: resource.connect_slot.id) : ConnectSlot.available).includes(:faculty),
        required: true
      f.input :startup, label: 'Product', collection: Startup.batched.approved.order(:product_name), required: true
      f.input :questions
      f.input :meeting_link
      f.input :status, as: :select, collection: ConnectRequest.valid_statuses, include_blank: false
    end

    f.actions
  end
end
