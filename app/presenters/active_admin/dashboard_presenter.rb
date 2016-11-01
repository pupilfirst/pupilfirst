module ActiveAdmin
  class DashboardPresenter
    attr_reader :intercom

    def initialize
      @intercom = IntercomClient.new
    end

    INTERCOM_METHODS = [:unassigned_conversations_count, :assigned_conversations_count, :open_conversations_count,
                        :closed_conversations_count, :new_users_count, :active_users_count].freeze

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
        students_total: MoocStudent.count,
        students_started: MoocStudent.where.not(completed_chapters: nil).count,
        quizzes_total: QuizAttempt.count,
        quizzes_distinct: QuizAttempt.distinct.count(:mooc_student_id)
      }
    end
  end
end
