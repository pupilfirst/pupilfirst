module Schools
  module Founders
    class EditForm < Reform::Form
      property :name, validates: { presence: true }
      property :team_name, virtual: true, validates: { presence: true, length: { maximum: 50 } }
      property :excluded_from_leaderboard, validates: { inclusion: { in: [true, false] } }
      property :tags, virtual: true
      property :coach_ids, virtual: true
      property :title, virtual: true, validates: { presence: true }
      property :affiliation, virtual: true
      property :access_ends_at, virtual: true

      def save
        Founder.transaction do
          school = model.school
          model.user.update!(name: name, title: title, affiliation: affiliation)

          model.startup.update!(name: override_team_name, access_ends_at: access_ends_at, tag_list: tags)
          model.excluded_from_leaderboard = excluded_from_leaderboard
          model.save!

          school.founder_tag_list << tags
          school.save!

          ::Startups::AssignReviewerService.new(model.startup).assign(coach_ids)
        end
      end

      private

      def override_team_name
        model.startup.founders.one? ? name : team_name
      end
    end
  end
end
