# Accepts talent queries and mails it to help@sv.co
class TalentForm < Reform::Form
  VALID_QUERY_TYPES = ['Hiring Founders', 'Investing in Startups', 'Acquihiring Teams', 'Accelerating Startups', 'Joining SV.CO as Faculty'].freeze

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :query_type, validates: { presence: true }
  property :mobile
  property :organization
  property :website

  validate :query_type_must_be_valid

  def query_type_must_be_valid
    query_type.delete('') if query_type.respond_to?(:delete)

    if query_type.blank?
      errors[:query_type] << 'must select at least one'
      return
    end

    valid_query_types_count = query_type.count do |type|
      type.in? VALID_QUERY_TYPES
    end

    return if valid_query_types_count == query_type.count
    errors[:query_type] << 'invalid types selected'
  end

  def send_mail
    TalentFormMailer.contact(name: name, email: email, mobile: mobile, organization: organization, website: website, query_type: query_type).deliver_later
  end
end
