module ActiveAdmin
  class DashboardPresenter
    attr_reader :intercom

    def initialize
      @intercom = IntercomClient.new
    end

    INTERCOM_METHODS = %i[unassigned_conversations_count assigned_conversations_count open_conversations_count closed_conversations_count new_users_count active_users_count].freeze

    INTERCOM_METHODS.each do |method_name|
      define_method method_name do
        begin
          intercom.public_send(method_name)
        rescue Exceptions::IntercomError
          'Error'
        end
      end
    end

    def mooc_stats
      @mooc_stats ||= {
        registrations_total: MoocStudent.count,
        registrations_started: MoocStudent.where.not(completed_chapters: nil).count,
        registrations_trend: MoocStudent.group_by_week(:created_at, last: 8).count.values.join(', '),
        quizzes_total: MoocQuizAttempt.count,
        quizzes_distinct: MoocQuizAttempt.distinct.count(:mooc_student_id),
        quizzes_trend: MoocQuizAttempt.group_by_week(:created_at, last: 8).count.values.join(', ')
      }
    end
  end
end
