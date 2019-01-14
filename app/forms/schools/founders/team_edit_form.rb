module Schools
  module Founders
    class TeamEditForm < Reform::Form
      property :product_name, validates: { presence: true }
    end
  end
end
