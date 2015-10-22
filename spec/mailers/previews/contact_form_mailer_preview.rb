class ContactFormMailerPreview < ActionMailer::Preview
  def contact
    ContactFormMailer.contact(
      name: 'Jack Sparrow',
      email: 'jack.sparrow@sv.co',
      query_type: 'Other',
      query: "Arr! I'm the captain!\n\nI should have been the CEO!\n\nArr!",
      mobile: '9666666666',
      company: 'Black Pearl Inc.'
    )
  end
end
