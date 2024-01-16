module Mutations
  class UpdateAssignment < ApplicationQuery
    include QueryAuthorizeAuthor
    include ValidateAssignmentEditable

    description "Update an assignment"

    field :id, ID, null: true

    def resolve(_params)
      if assignment
        updated_assignment =
          ::Assignments::UpdateService.new(assignment).execute(
            assignment_params
          )
        { id: updated_assignment.id }
      else
        { id: nil }
      end
    end

    def resource_school
      course&.school
    end

    def assignment
      assignment ||= Assignment.find_by(target_id: @params[:target_id])
      if !assignment && !@params[:archived]
        assignment =
          target.assignments.create!(
            target_id: @params[:target_id],
            role: @params[:role]
          )
      end
      @assignment = assignment
    end

    def target
      @target ||= Target.find_by(id: @params[:target_id])
    end

    def course
      target&.course
    end
  end
end
