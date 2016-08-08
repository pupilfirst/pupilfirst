class University < ActiveRecord::Base
  has_many :founders, dependent: :restrict_with_error

  validates_uniqueness_of :name, presence: true
  validates_presence_of :location

  def self.valid_state_names
    [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
      'Himachal Pradesh', 'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
      'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
      'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman and Nicobar', 'Chandigarh',
      'Dadra and Nagar Haveli', 'Daman and Diu', 'Lakshadweep', 'Delhi', 'Puducherry', 'Outside India'
    ]
  end

  # Returns the university designated as 'Other not in the list'.
  def self.other
    if Rails.env.production?
      find(8)
    else
      where("name LIKE '%Other%'").first
    end
  end

  # Searches for a university with a term. Always returns 'other' university in search results.
  def self.select2_search(term)
    query = "%#{term}%"
    universities = where('name ILIKE ? OR location ILIKE ? OR id = ?', query, query, other.id)

    universities.select(:id, :location, :name).group_by(&:location).each_with_object([]) do |search_result, results|
      results << {
        text: search_result[0],
        children: search_result[1].map do |university|
          {
            id: university.id,
            text: university.name
          }
        end
      }
    end
  end
end
