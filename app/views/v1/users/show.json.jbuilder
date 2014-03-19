path = "#{__FILE__.match(/v\d/)[0]}/users/user"

extra_block = Proc.new do
  json.startup_meta_details do
    json.approval_status @user.startup.approval_status
    json.incorporation do
      json.is_enabled @user.incorporation_enabled?
      json.message @user.startup.incorporation_message
    end
    json.banking do
      json.is_enabled @user.bank_details_enabled?
      json.message @user.startup.banking_message
    end
    json.sep do
      json.is_enabled @user.sep_enabled?
      json.message nil
    end
    json.personal_info do
      json.is_enabled @user.profile_info_enabled?
      json.message nil
    end

  end
end
json.partial! path, user: @user, details_level: :full, extra_block: (@extra_info ? extra_block : nil)
