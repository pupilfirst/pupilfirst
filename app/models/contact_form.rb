class ContactForm
  include ActiveModel::Model

  attr_writer :name, :email, :mobile, :company
  attr_accessor :founder, :query_type, :query

  validates_presence_of :name, :email, :query_type, :query
  validates_format_of :email, with: /@/

  def self.valid_query_types
    ['Media Relations Query', 'Incubation Help', 'Education Help', 'Space Availability Question', 'Other']
  end

  validates_inclusion_of :query_type, in: valid_query_types

  def name
    @name || founder.try(:fullname)
  end

  def email
    @email || founder.try(:email)
  end

  def mobile
    @mobile || founder.try(:mobile)
  end

  def company
    @company || founder.try(:startup).try(:display_name)
  end

  def save
    return unless valid?

    ContactFormMailer.contact(name: name, email: email, mobile: mobile, company: company, query_type: query_type, query: query).deliver_later
  end
end
