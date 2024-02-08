class RenameIconToIconOnLightBg < ActiveRecord::Migration[7.0]
  def change
    ActiveStorage::Attachment.where(
      record_type: "School",
      name: "icon"
    ).update_all(name: "icon_on_light_bg")
  end
end
