module Schools
  module Founders
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
      property :team_name, virtual: true, validates: { presence: true }
      property :tags

      def save
        Founder.transaction do
          model.startup.update!(product_name: team_name)
          model.name = name
          model.tag_list = tags
          model.save!

          school = model.school
          school.founder_tag_list << tags
          school.save!
        end
      end
    end
  end
end
