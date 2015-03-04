# class StudentEntrepreneurPolicy < ActiveRecord::Base
#   belongs_to :user
#   mount_uploader :certificate_pic, AvatarUploader
#   process_in_background :certificate_pic

#   validates_associated :user
#   validates_presence_of :certificate_pic
#   validates_presence_of :university_registration_number
#   validates_presence_of :address

#   after_create do
#     UserMailer.new_sep_notification(user).deliver_later
#   end
# end
