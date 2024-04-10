module CourseExports
  class PrepareUserStandingsExportService
    def execute(user_ids)
      { title: "User Standings", rows: user_standing_rows(user_ids) }
    end

    def user_standing_rows(user_ids)
      users_standings = UserStanding.includes(:user, :standing, :creator, :archiver)
                                    .where(user_id: user_ids)
                                    .order('users.email' => :asc, created_at: :desc)


      header_row = [
        "User ID",
        "Email Address",
        "Name",
        "Standing Name",
        "Reason",
        "Created At",
        "Created by",
        "Archived at",
        "Archived by"
      ]

      data_rows = users_standings.map do |user_standing|
        [
          user_standing.user_id,
          user_standing.user.email,
          user_standing.user.name,
          user_standing.standing.name,
          user_standing.reason,
          user_standing.created_at.iso8601,
          user_standing.creator.name,
          user_standing.archived_at&.iso8601,
          user_standing.archiver&.name
        ]
      end

      [header_row] + data_rows
    end
  end
end
