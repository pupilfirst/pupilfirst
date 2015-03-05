require 'open-uri'

class SendSepJob < ActiveJob::Base
  include UsersHelper

  def perform(sep_id)
    ActiveRecord::Base.connection_pool.with_connection do
      sep = StudentEntrepreneurPolicy.find sep_id
      rand_hex = SecureRandom.hex
      tmp_out = "/tmp/svapp_#{rand_hex}.pdf"
      profile_pic = "/tmp/svapp_prof_#{rand_hex}"
      signature_pic = "/tmp/svapp_sin_#{rand_hex}"
      open(profile_pic, 'wb') do |file|
        file << open(sep.certificate_pic_url(:mid)).read
      end
      open(signature_pic, 'wb') do |file|
        path = File.join(Rails.root, "app/assets/private/signature.jpg")
        file << open(path).read
      end
      generate_sep_pdf(tmp_out, profile_pic, signature_pic, data={
        fullname: sep.user.fullname,
        born_on: sep.user.born_on,
        gender: sep.user.gender,
        college: sep.user.college,
        course: sep.user.course,
        company_name: sep.user.startup.name,
        title: sep.user.title,
        semester: sep.user.semester,
        university: sep.user.university,
        university_registration_number: sep.university_registration_number,
        address: sep.address
      })
      UserMailer.send_sep_certificate(sep.user, tmp_out).deliver_later
    end
  end
end
