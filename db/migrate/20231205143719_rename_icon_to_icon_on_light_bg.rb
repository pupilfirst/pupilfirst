class RenameIconToIconOnLightBg < ActiveRecord::Migration[6.1]
  def change
    ActiveStorage::Attachment.where(name: "icon").update(
      name: "icon_on_light_bg"
    )
  end
end
