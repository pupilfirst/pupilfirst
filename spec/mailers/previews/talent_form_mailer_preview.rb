class TalentFormMailerPreview < ActionMailer::Preview
  def contact
    mail_params = {
      name: 'John Doe',
      email: 'johndoe@example.com',
      mobile: '9876543210',
      organization: 'Doe Enterprises',
      website: 'https://www.example.com',
      query_type: TalentForm::VALID_QUERY_TYPES.sample(rand(3) + 1)
    }

    TalentFormMailer.contact(mail_params)
  end
end
