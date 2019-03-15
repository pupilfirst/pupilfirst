module Courses
  class LeaderboardPresenter < ApplicationPresenter
    def initialize(view_context, course, page: nil)
      @course ||= course
      @page = page

      super(view_context)
    end

    def school_name
      @school_name ||= begin
        raise 'current_school cannot be missing here' if current_school.blank?

        current_school.name
      end
    end

    def start_datestring
      last_week_start_time.strftime('%B %-d')
    end

    def end_datestring
      last_week_end_time.strftime('%B %-d')
    end

    def toppers
      @toppers ||= entries.find_all { |e| e[:rank] == 1 }
    end

    def heading
      if current_founder_is_topper?
        return '<strong>You</strong> are at the top of the leaderboard. <strong>Congratulations!</strong>'.html_safe
      end

      multiple_mid_text = 'are at the top of the leaderboard this week, sharing a score of '

      h = if toppers.count == 1
        "<strong>#{toppers.first[:founder].name}</strong> is at the top of the leaderboard this week with a score of "
      elsif toppers.count < 4
        names = toppers.map { |s| "<strong>#{s[:founder].name}</strong>" }
        "#{names.to_sentence} #{multiple_mid_text}"
      else
        others_count = toppers.count - 2
        names = toppers[0..1].map { |s| "<strong>#{s[:founder].name}</strong>" }
        "#{names.join(', ')} and #{others_count} others #{multiple_mid_text}"
      end

      (h + "<strong>#{top_score}</strong>.").html_safe
    end

    def entries
      @entries ||= begin
        current_leaderboard.values.map do |entry|
          last_entry_rank = last_leaderboard.dig(entry[:founder].id, :rank)

          delta = if last_entry_rank.present?
            last_entry_rank - entry[:rank]
          end

          delta_icon = if delta.present?
            delta.positive? ? 'chevron-up' : 'chevron-down'
          else
            'plus'
          end

          entry.merge(delta_icon: delta_icon, delta: delta)
        end
      end
    end

    def inactive_students_count
      @inactive_students_count ||= founders.count - entries.count
    end

    def previous_page?
      page < 8
    end

    def next_page?
      page.positive?
    end

    def previous_page_link
      view.leaderboard_course_path(page: page + 1)
      "?page=#{page + 1}"
    end

    def next_page_link
      if page == 1
        view.leaderboard_course_path
      else
        view.leaderboard_course_path(page: page - 1)
      end
    end

    def last_week_start_time
      week_beginning(leaderboard_at - 1.week).in_time_zone('Asia/Calcutta') + 12.hours
    end

    def last_week_end_time
      week_beginning(leaderboard_at).in_time_zone('Asia/Calcutta') + 12.hours
    end

    def course_entries(from, to)
      LeaderboardEntry.where(founder: founders, period_from: from, period_to: to)
    end

    private

    def top_score
      @top_score ||= toppers.first[:score]
    end

    def current_founder_is_topper?
      current_founder.present? && current_founder.id.in?(toppers.map { |s| s[:founder].id })
    end

    def leaderboard_at
      @leaderboard_at ||= Time.zone.now - page.weeks
    end

    def page
      @page ||= begin
        parsed_page = view.params[:page].to_i
        parsed_page.between?(0, 12) ? parsed_page : 0
      end
    end

    def founders
      @course.founders.not_exited
    end

    def current_leaderboard
      @current_leaderboard ||= load_leaderboard_entries(last_week_start_time, last_week_end_time)
    end

    def last_leaderboard
      @last_leaderboard ||= load_leaderboard_entries(week_before_last_start_time, last_week_start_time)
    end

    def load_leaderboard_entries(from, to)
      last_rank = 0
      last_score = BigDecimal::INFINITY

      course_entries(from, to).order(score: :DESC).each_with_object({}).with_index(1) do |(entry, entries), index|
        rank = entry.score < last_score ? index : last_rank

        entries[entry.founder.id] = { rank: rank, founder: entry.founder, score: entry.score }

        last_rank = rank
        last_score = entry.score
      end
    end

    def week_before_last_start_time
      week_beginning(leaderboard_at - 2.weeks).in_time_zone('Asia/Calcutta') + 12.hours
    end

    def week_beginning(time)
      if monday?(time) && before_noon?(time)
        (time - 1.day)
      else
        time
      end.beginning_of_week
    end

    def monday?(time)
      time.wday == 1
    end

    def before_noon?(time)
      time.hour < 12
    end
  end
end
