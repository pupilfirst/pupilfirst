module CollegeNameable
  extend ActiveSupport::Concern

  included do
    validates_with CollegeIdOrTextValidator
  end

  def college_name
    college&.name || college_text
  end
end
