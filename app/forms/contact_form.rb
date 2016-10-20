# Accepts queries and mails it to help@sv.co
class ContactForm < Reform::Form
  VALID_QUERY_TYPES = ['Media Relations Query', 'Incubation Help', 'Education Help', 'Space Availability Question', 'Startup India Recommendation Query', 'Other'].freeze

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :query_type, validates: { presence: true, inclusion: { in: VALID_QUERY_TYPES } }
  property :query, validates: { presence: true }
  property :mobile
  property :company

  def prepopulate!(founder)
    return unless founder.present?

    self.email = founder&.email
    self.name = founder&.fullname
    self.mobile = founder&.phone
    self.company = founder&.startup&.display_name
  end

  def send_mail
    ContactFormMailer.contact(name: name, email: email, mobile: mobile, company: company, query_type: query_type, query: query).deliver_later
  end
end
