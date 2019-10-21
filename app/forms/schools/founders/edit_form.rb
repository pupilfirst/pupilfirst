module Schools
  module Founders
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
      property :team_name, virtual: true, validates: { presence: true }
      property :exited, validates: { inclusion: { in: [true, false] } }
      property :excluded_from_leaderboard, validates: { inclusion: { in: [true, false] } }
      property :tags
      property :coach_ids, virtual: true
      property :title, virtual: true, validates: { presence: true }
      property :affiliation, virtual: true

      def save
        Founder.transaction do
          school = model.school
          model.user.update!(name: name, title: title, affiliation: affiliation)

          model.startup.update!(name: override_team_name)
          model.tag_list = tags
          model.excluded_from_leaderboard = excluded_from_leaderboard
          model.save!

          school.founder_tag_list << tags
          school.save!

          handle_exited(model, exited)
        end
      end

      private

      def override_team_name
        model.startup.founders.one? ? name : team_name
      end

      def handle_exited(founder, exited)
        if exited
          ::Founders::MarkAsExitedService.new(model.id).execute
        else
          # Re-assign team coaches.
          ::Startups::AssignReviewerService.new(founder.startup).assign(coach_ids)

          # Reset exited if it has changed.
          founder.update!(exited: false) if founder.exited?
        end
      end
    end
  end
end
