module ValidateTargetEditable
  extend ActiveSupport::Concern

  class ValidateTargetAndEvaluationCriteria < GraphQL::Schema::Validator
    include ValidatorCombinable

    def validate(_object, _context, value)
      @target = Target.find_by(id: value[:id])
      @course = @target.course
      @target_group =
        @course.target_groups.where(id: value[:target_group_id]).first
      @evaluation_criteria = value[:evaluation_criteria]

      combine(target_group_exists, same_course_for_target_and_ec, target_exists)
    end

    def target_group_exists
      return if @target_group.present?

      I18n.t("mutations.update_target.target_group_not_present_error")
    end

    def target_exists
      return if @target.present?

      I18n.t("mutations.update_target.target_missing_error")
    end
  end

  included do
    argument :id, GraphQL::Types::ID, required: true
    argument :title, GraphQL::Types::String, required: true
    argument :target_group_id, GraphQL::Types::ID, required: true
    argument :visibility, GraphQL::Types::String, required: true
  end

  def target_params
    {
      title: @params[:title],
      visibility: @params[:visibility],
      target_group_id: @params[:target_group_id]
    }
  end
end
