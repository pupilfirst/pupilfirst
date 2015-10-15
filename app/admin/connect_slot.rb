ActiveAdmin.register ConnectSlot do
  permit_params :faculty_id, :slot_at_date, :slot_at_time_hour, :slot_at_time_minute

  menu parent: 'Faculty'

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
    @faculty = Faculty.where(available_for_connect: true)
  end

  collection_action :create_multiple, method: :post do
    faculty = Faculty.find(params[:connect_slots][:faculty])

    new_slots = []

    params[:connect_slots][:slots].split(',').each do |slot|
      hour = slot.to_i
      minute = (((slot.to_f) - hour) * 60).to_s.delete('.')[0..1]

      connect_slot = faculty.connect_slots.find_or_initialize_by(
        slot_at: Time.parse("#{params[:connect_slots][:date]} #{hour.to_s.rjust(2, '0')}:#{minute}:00 +0530")
      )

      unless connect_slot.persisted?
        connect_slot.save!
        new_slots << connect_slot
      end
    end

    flash[:success] = "#{new_slots.count} slots have been created for #{faculty.name}"

    redirect_to admin_connect_slots_path
  end

  action_item :add_multiple, only: :index do
    link_to 'Create multiple slots at once', add_multiple_admin_connect_slots_path
  end

  form do |f|
    f.inputs 'Connect Slot Details' do
      f.input :faculty, collection: Faculty.where(available_for_connect: true)
      f.input :slot_at, as: :just_datetime_picker
    end

    f.actions
  end
end
