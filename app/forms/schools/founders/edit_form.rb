module Schools
  module Founders
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
      property :team_name, virtual: true, validates: { presence: true }
      property :exited, validates: { inclusion: { in: [true, false] } }
      property :excluded_from_leaderboard, validates: { inclusion: { in: [true, false] } }
      property :tags

      def save
        Founder.transaction do
          model.startup.update!(name: team_name)
          model.name = name
          model.tag_list = tags
          model.excluded_from_leaderboard = excluded_from_leaderboard
          model.save!

          school = model.school
          school.founder_tag_list << tags
          school.save!

          handle_exited(model, exited)
        end
      end

      private

      def handle_exited(founder, exited)
        if exited
          ::Founders::MarkAsExitedService.new(model.id).execute
        else
          founder.update!(exited: exited)
        end
      end
    end
  end
end
