# Mails sent out from the contact form.
class TalentFormMailer < ApplicationMailer
  # Since there's no DB table supporting TalentForm, this method accepts all data (to allow serialization).
  def contact(mail_params)
    @name = mail_params[:name]
    @email = mail_params[:email]
    @mobile = mail_params[:mobile]
    @organization = mail_params[:organization]
    @query_type = mail_params[:query_type]

    mail(to: 'help@sv.co', subject: "Talent Form: #{@query_type.join ', '} (by #{@name})", reply_to: @email)
  end
end
