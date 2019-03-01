module Schools
  module Startups
    class EditForm < Reform::Form
      property :product_name, validates: { presence: true }
    end
  end
end
