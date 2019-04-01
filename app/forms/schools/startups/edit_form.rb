module Schools
  module Startups
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
    end
  end
end
