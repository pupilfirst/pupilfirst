class TalentForm
  include ActiveModel::Model

  attr_accessor :name, :email, :mobile, :organization, :query_type

  validates_presence_of :name, :email, :mobile, :query_type, :organization
  validates_format_of :email, with: /@/

  def self.valid_query_types
    ['Hiring Founders', 'Investing in Startups', 'Acquihiring Teams', 'Accelerating Startups', 'Joining SV.CO as Faculty']
  end

  validate :validate_query_types

  def validate_query_types
    query_type.delete('')

    if query_type.blank?
      errors[:query_type] << 'must select at least one'
      return
    end

    valid_query_types_count = query_type.select do |type|
      TalentForm.valid_query_types.include? type
    end.count

    unless valid_query_types_count == query_type.count
      errors[:query_type] << 'invalid types selected'
    end
  end

  def save
    return unless valid?

    TalentFormMailer.contact(name: name, email: email, mobile: mobile, organization: organization, query_type: query_type).deliver_later
  end
end
