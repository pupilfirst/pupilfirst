module Users
  class UploadAvatarForm < Reform::Form
    property :avatar, virtual: true, validates: { image: true, file_size: { less_than: 5.megabytes } }

    def save
      User.transaction do
        model.avatar.attach(avatar)
        model.avatar_url(variant: :mid)
      end
    end
  end
end
