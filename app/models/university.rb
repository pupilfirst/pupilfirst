class University < ActiveRecord::Base
  has_many :founders, dependent: :restrict_with_error

  validates_uniqueness_of :name, presence: true
  validates_presence_of :location

  def self.grouped_by_location
    all.each_with_object({}) do |university, grouped|
      grouped[university.location] ||= []
      grouped[university.location] << [university.id, university.name]
    end
  end

  def self.valid_state_names
    [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
      'Himachal Pradesh', 'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
      'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
      'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman and Nicobar', 'Chandigarh',
      'Dadra and Nagar Haveli', 'Daman and Diu', 'Lakshadweep', 'Delhi', 'Puducherry'
    ]
  end
end
