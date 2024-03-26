module Courses
  class LeaderboardPresenter < ApplicationPresenter
    class Student < SimpleDelegator
      attr_reader :score, :rank
      attr_accessor :delta

      def initialize(student, score, rank, current_user)
        @score = score
        @rank = rank
        @current_user = current_user

        super(student)
      end

      def level_number
        @level_number ||= level.number
      end

      def current_student?
        @current_student ||= (user_id == @current_user&.id)
      end
    end

    def initialize(view_context, course, params_on)
      @course = course
      @params_on = params_on

      super(view_context)
    end

    def school_name
      @school_name ||=
        begin
          raise "current_school cannot be missing here" if current_school.blank?

          current_school.name
        end
    end

    def start_date
      lts.week_start.strftime("%B %-d")
    end

    def end_date
      lts.week_end.strftime("%B %-d")
    end

    def toppers
      @toppers ||= students.find_all { |e| e.rank == 1 }
    end

    def heading
      if current_user_is_topper?
        return(
          I18n.t("presenters.courses.leaderboard.heading.top_leaderboard_html")
        )
      end

      multiple_mid_text =
        I18n.t("presenters.courses.leaderboard.heading.multiple_mid_text")

      h =
        if toppers.count == 1
          "<span class='font-bold'>#{toppers.first.name}</span> #{I18n.t("presenters.courses.leaderboard.heading.top_week")} "
        elsif toppers.count < 4
          names = toppers.map { |s| "<span class='font-bold'>#{s.name}</span>" }
          "#{names.to_sentence} #{multiple_mid_text}"
        else
          others_count = toppers.count - 2
          names =
            toppers[0..1].map { |s| "<span class='font-bold'>#{s.name}</span>" }
          "#{names.join(", ")} #{I18n.t("shared.and")} <span class='font-bold'>#{others_count} #{I18n.t("presenters.courses.leaderboard.heading.others")}</span> #{multiple_mid_text}"
        end

      (h + "<span class='font-bold'>#{top_score}</span>.").html_safe
    end

    def students
      @students ||=
        begin
          current_leaderboard.map do |student_id, student|
            delta =
              if last_leaderboard[student_id].present?
                last_leaderboard[student_id].rank - student.rank
              end

            student.delta = delta
            student
          end
        end
    end

    def inactive_students_count
      @inactive_students_count ||= active_students.count - students.count
    end

    def previous_page?
      difference_in_days < 120
    end

    def next_page?
      difference_in_days.positive?
    end

    def previous_page_link
      "?on=#{(on - 1.week).strftime("%Y%m%d")}"
    end

    def next_page_link
      if difference_in_days < 8
        view.leaderboard_course_path
      else
        "?on=#{(on + 1.week).strftime("%Y%m%d")}"
      end
    end

    def course_entries(from, to)
      LeaderboardEntry.where(
        student: active_students,
        period_from: from,
        period_to: to
      ).includes(student: [user: { avatar_attachment: :blob }])
    end

    def rank_change_icon(delta)
      if delta >= 10
        view.image_tag(
          "courses/leaderboard/rank-change-up-double.svg",
          alt:
            I18n.t(
              "presenters.courses.leaderboard.rank_change_icon.rank_change_double_alt"
            )
        )
      elsif delta.positive?
        view.image_tag(
          "courses/leaderboard/rank-change-up.svg",
          alt:
            I18n.t(
              "presenters.courses.leaderboard.rank_change_icon.rank_up_alt"
            )
        )
      elsif delta.zero?
        view.image_tag(
          "courses/leaderboard/rank-no-change.svg",
          alt:
            I18n.t(
              "presenters.courses.leaderboard.rank_change_icon.rank_no_change_alt"
            )
        )
      elsif delta > -10
        view.image_tag(
          "courses/leaderboard/rank-change-down.svg",
          alt:
            I18n.t(
              "presenters.courses.leaderboard.rank_change_icon.rank_down_alt"
            )
        )
      else
        view.image_tag(
          "courses/leaderboard/rank-change-down-double.svg",
          alt:
            I18n.t(
              "presenters.courses.leaderboard.rank_change_icon.rank_down_double_alt"
            )
        )
      end
    end

    def format_delta(delta)
      return if delta.blank?

      delta.negative? ? delta * -1 : delta
    end

    private

    def difference_in_days
      @difference_in_days = (Time.zone.now.to_date - on.to_date).to_i
    end

    def top_score
      @top_score ||= toppers.first.score
    end

    def current_user_is_topper?
      current_user.present? && current_user.id.in?(toppers.map(&:user_id))
    end

    def on
      @on ||=
        begin
          if @params_on.present? &&
               @params_on.match?(
                 /\A20\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])\Z/
               )
            Time.zone.parse(@params_on).end_of_day
          else
            Time.zone.now
          end
        end
    end

    def lts
      @lts ||= LeaderboardTimeService.new(on)
    end

    def active_students
      @active_students ||=
        @course.students.active.where(excluded_from_leaderboard: false)
    end

    def current_leaderboard
      @current_leaderboard ||= ranked_students(lts.week_start, lts.week_end)
    end

    def last_leaderboard
      @last_leaderboard ||=
        ranked_students(lts.last_week_start, lts.last_week_end)
    end

    def ranked_students(from, to)
      last_rank = 0
      last_score = BigDecimal::INFINITY

      course_entries(from, to)
        .order(score: :DESC)
        .each_with_object({})
        .with_index(1) do |(entry, students), index|
          rank = entry.score < last_score ? index : last_rank

          students[entry.student.id] = Student.new(
            entry.student,
            entry.score,
            rank,
            current_user
          )

          last_rank = rank
          last_score = entry.score
        end
    end
  end
end
