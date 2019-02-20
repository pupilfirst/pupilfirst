module Schools
  module Founders
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
      property :team_name, virtual: true, validates: { presence: true }

      def save
        Founder.transaction do
          model.startup.update!(product_name: team_name)
          model.update!(name: name)
        end
      end
    end
  end
end
