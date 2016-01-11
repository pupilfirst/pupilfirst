# Mails sent out from the contact form.
class ContactFormMailer < ApplicationMailer
  # Since there's no DB table supporting ContactForm, this method accepts all data (to allow serialization).
  def contact(contact_params)
    @name = contact_params[:name]
    @email = contact_params[:email]
    @mobile = contact_params[:mobile]
    @company = contact_params[:company]
    @query_type = contact_params[:query_type]
    @query = contact_params[:query]

    mail(to: 'help@sv.co', subject: "#{@query_type} (by #{@name})", reply_to: @email)
  end
end
