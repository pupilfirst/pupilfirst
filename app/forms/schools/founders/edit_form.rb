module Schools
  module Founders
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
    end
  end
end
