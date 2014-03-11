	path = "#{__FILE__.match(/v\d/)[0]}/users/user"

status_block = -> name, status, message {
  json.set! name do
    json.status status
    json.message message
  end
}

  extra_block = Proc.new do
    json.startup_meta_details do
      json.approval_status false
      json.next_process 'incorporation'
      json.incorporation status_block.('incorporation', false, '')
      json.banking status_block.('banking', false, '')
      json.sep status_block.('sep', false, '')
      json.director_info do
        json.pan_status true
        json.din_status true
      end
    end
  end
	json.partial! path, user: @user, details_level: :full, extra_block: extra_block
