module ValidateAssignmentEditable
  extend ActiveSupport::Concern

  class ValidateAssignmentAndEvaluationCriteria < GraphQL::Schema::Validator
    include ValidatorCombinable

    def validate(_object, _context, value)
      @target = Target.find_by(id: value[:target_id])
      @assignment = Assignment.find_by(target_id: value[:target_id])
      @course = @target.course
      @evaluation_criteria = value[:evaluation_criteria]

      combine(same_course_for_assignment_and_ec, target_exists)
    end

    def same_course_for_assignment_and_ec
      if @course.evaluation_criteria.where(id: @evaluation_criteria).count ==
           @evaluation_criteria.count
        return
      end

      I18n.t("mutations.update_target.evaluation_criteria_course_error")
    end

    def target_exists
      return if @target.present?

      I18n.t("mutations.update_target.target_missing_error")
    end
  end

  class OnlyOneMethodOfCompletion < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      completion_criteria = [
        value[:evaluation_criteria].present?,
        value[:quiz].present?
      ]

      return if completion_criteria.one? || completion_criteria.none?

      I18n.t("mutations.update_target.multiple_method_of_completion")
    end
  end

  class ChecklistHasValidData < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      evaluation_criteria = value[:evaluation_criteria]
      checklist = value[:checklist].map { |cl| cl.permit!.to_h }

      return if evaluation_criteria.blank? && checklist.blank?

      if validate_checklist(checklist) &&
           required_items_have_unique_titles(checklist)
        return
      end

      I18n.t("mutations.update_target.invalid_checklist_error")
    end

    def valid_string(string)
      string.is_a?(String) && string.strip.present?
    end

    def valid_checklist_kind(kind)
      kind.is_a?(String) && Assignment.valid_checklist_kind_types.include?(kind)
    end

    def valid_metadata(item)
      if item["kind"] != Assignment::CHECKLIST_KIND_MULTI_CHOICE &&
           item["metadata"] == {}
        return true
      end

      item["metadata"]["choices"].length >= 1 &&
        item["metadata"]["choices"].all? { |choice| valid_string(choice) } &&
        item["metadata"]["allowMultiple"] == !!item["metadata"]["allowMultiple"]
    end

    def validate_checklist(checklist)
      checklist.respond_to?(:all?) &&
        checklist.all? do |item|
          valid_string(item["title"]) && valid_checklist_kind(item["kind"]) &&
            (item["optional"] == !!item["optional"]) && valid_metadata(item)
        end
    end

    def required_items_have_unique_titles(checklist)
      required_items = checklist.reject { |item| item["optional"] }

      required_items.map { |item| item["title"].strip }.uniq.count ==
        required_items.count
    end
  end

  class ChecklistHasValidLength < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      checklist = value[:checklist]

      return if checklist.respond_to?(:all?) && checklist.length <= 25

      I18n.t("mutations.update_target.checklist_items_exceeded_error")
    end
  end

  class PrerequisitesNotArchived < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      prerequisite_targets = value[:prerequisite_targets]
      prerequisite_assignments =
        Assignment.where(target_id: prerequisite_targets)
      non_archived_assignments = prerequisite_assignments.not_archived
      non_archived_targets =
        Target
          .where(id: prerequisite_targets)
          .where.not(visibility: Target::VISIBILITY_ARCHIVED)

      if prerequisite_targets.uniq.count == non_archived_targets.count &&
           prerequisite_assignments.count == non_archived_assignments.count
        return
      end

      I18n.t("mutations.update_target.prerequisities_archived_error")
    end
  end

  class TargetNotPrerequisiteToItself < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      prerequisite_targets = value[:prerequisite_targets]

      return unless prerequisite_targets.include?(value[:id])

      I18n.t("mutations.update_target.prerequisities_self_error")
    end
  end

  included do
    argument :target_id, GraphQL::Types::ID, required: true
    argument :role, GraphQL::Types::String, required: true
    argument :evaluation_criteria, [GraphQL::Types::ID], required: true
    argument :prerequisite_targets, [GraphQL::Types::ID], required: true
    argument :quiz, [Types::AssignmentQuizInputType], required: true
    argument :completion_instructions, GraphQL::Types::String, required: false
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :milestone, GraphQL::Types::Boolean, required: true
    argument :archived, GraphQL::Types::Boolean, required: false
    argument :discussion, GraphQL::Types::Boolean, required: true
    argument :allow_anonymous, GraphQL::Types::Boolean, required: false

    validates ValidateAssignmentAndEvaluationCriteria => {}
    validates PrerequisitesNotArchived => {}
    validates OnlyOneMethodOfCompletion => {}
    validates ChecklistHasValidData => {}
    validates ChecklistHasValidLength => {}
    validates TargetNotPrerequisiteToItself => {}
  end

  def assignment_params
    {
      target_id: @params[:target_id],
      role: @params[:role],
      prerequisite_target_ids: @params[:prerequisite_targets],
      evaluation_criterion_ids: @params[:evaluation_criteria],
      quiz: @params[:quiz],
      completion_instructions: @params[:completion_instructions],
      checklist: @params[:checklist],
      milestone: @params[:milestone],
      archived: @params[:archived],
      discussion: @params[:discussion],
      allow_anonymous: @params[:allow_anonymous]
    }
  end
end
