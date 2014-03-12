	path = "#{__FILE__.match(/v\d/)[0]}/users/user"

status_block = -> name, is_enabled, status, message {
  json.set! name do
    json.is_enabled is_enabled
    json.status status
    json.message message
  end
}

  extra_block = Proc.new do
    json.startup_meta_details do
      json.approval_status true
      json.next_process 'incorporation'
      json.incorporation status_block.('incorporation', true, false, '')
      json.banking status_block.('banking', false, false, '')
      json.sep status_block.('sep', false, false, '')
      json.personal_info status_block.('personal_info', true, false, '')

    end
  end
	json.partial! path, user: @user, details_level: :full, extra_block: extra_block
