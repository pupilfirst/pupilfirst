class MoocStudent < ActiveRecord::Base
  belongs_to :university
  belongs_to :user

  def self.valid_semester_values
    %w(I II III IV V VI VII VIII Graduated Other)
  end
end
