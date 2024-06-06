module CourseExports
  class PrepareUserStandingsExportService
    HEADER_ROW = [
      "User ID",
      "Email address",
      "Name",
      "Standing",
      "Log entry",
      "Created at",
      "Created by",
      "Archived at",
      "Archived by"
    ].freeze

    BATCH_SIZE = 1000.0

    def execute(user_ids)
      { title: "User Standings", rows: user_standing_rows(user_ids) }
    end

    def user_standing_rows(user_ids)
      total_records = UserStanding.where(user_id: user_ids).count
      total_batches = (total_records / BATCH_SIZE ).ceil

      data_rows = (1..total_batches).flat_map do |batch|
        offset = (batch - 1) * BATCH_SIZE

        UserStanding.includes(:user, :standing, :creator, :archiver)
                     .where(user_id: user_ids)
                     .order('users.email' => :asc, created_at: :desc)
                     .limit(BATCH_SIZE)
                     .offset(offset)
                     .map do |user_standing|
                       [
                         user_standing.user.id,
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
      end
      [HEADER_ROW] + data_rows
    end
  end
end
