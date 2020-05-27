ActiveAdmin.register ConnectSlot do
  permit_params :faculty_id, :slot_at

  menu parent: 'Faculty'

  filter :faculty_user_name, as: :string
  filter :faculty_category_eq, label: 'Facutly Type', as: :select, collection: -> { Faculty.valid_categories }
  filter :slot_at

  scope :available_for_founder

  index do
    selectable_column

    column :faculty
    column :slot_at do |connect_slot|
      connect_slot.slot_at.in_time_zone('Asia/Calcutta').strftime('%b %-d, %-I:%M %p')
    end

    actions
  end

  collection_action :add_multiple, method: :get do
    @connect_slot = ConnectSlot.new
    @faculty = Faculty.available_for_connect.order(:name)
  end

  collection_action :create_multiple, method: :post do
    faculty = Faculty.find(params[:connect_slots][:faculty])

    new_slots = []

    begin
      (Date.parse(params[:connect_slots][:date_start])..Date.parse(params[:connect_slots][:date_end])).each do |day|
        params[:connect_slots][:slots].split(',').each do |slot|
          hour = slot.to_i
          minute = ((slot.to_f - hour) * 60).to_s.delete('.')[0..1]

          connect_slot = faculty.connect_slots.find_or_initialize_by(
            slot_at: Time.parse("#{day.strftime('%Y-%m-%d')} #{hour.to_s.rjust(2, '0')}:#{minute}:00 +0530")
          )

          unless connect_slot.persisted?
            connect_slot.save!
            new_slots << connect_slot
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
    else
      flash[:success] = "#{new_slots.count} slots have been created for #{faculty.name}"
    end

    redirect_to admin_connect_slots_path
  end

  action_item :add_multiple, only: :index do
    link_to 'Create multiple slots at once', add_multiple_admin_connect_slots_path
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Connect Slot Details' do
      f.input :faculty, collection: Faculty.available_for_connect.order(:name)
      f.input :slot_at, as: :string, input_html: { class: 'date-time-picker', data: { format: 'Y-m-d H:i:s O', step: 30 } }, placeholder: 'YYYY-MM-DD HH:MM:SS'
    end

    f.actions
  end
end
