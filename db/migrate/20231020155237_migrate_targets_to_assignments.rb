class MigrateTargetsToAssignments < ActiveRecord::Migration[6.1]
  def change
    assignments = []
    Target.includes(:quiz, :target_prerequisites).find_each do |target|
      assignment_hash = {
        :target_id => target.id,
        :role => target.role,
        :completion_instructions => target.completion_instructions,
        :milestone => target.milestone,
        :milestone_number => target.milestone_number,
        :checklist => target.checklist,
        :created_at => target.created_at,
        :updated_at => target.updated_at,
        :archived => false
      }
      if target.mark_as_complete?
        if !target.target_prerequisites.empty? or !target.prerequisite_targets.empty? or target.milestone?
          # convert mark as complete to a form submit assignment
          assignment_hash[:checklist] = [{"kind"=>"multiChoice", "title"=>"Mark this target as completed?", "metadata"=>{"choices"=>["Yes"], "allowMultiple"=>false}, "optional"=>false}]
        else
          target.timeline_events.destroy_all
          # skip creating assignment
          next
        end
      end

      if target.link_to_complete.present?
        #TODO - add a mardown content block for the link
        if !target.target_prerequisites.empty? or !target.prerequisite_targets.empty? or target.milestone?
          assignment_hash[:checklist] = [{"kind"=>"multiChoice", "title"=>"Have you gone through the shared link?", "metadata"=>{"choices"=>["Yes"], "allowMultiple"=>false}, "optional"=>false}]
        else
          target.timeline_events.destroy_all
          # skip creating assignment
          next
        end
      end
      assignments.append(assignment_hash)
    end

    Assignment.insert_all(assignments)

    # TODO One sql read and wirte per iteration - see if there are too many quizzes
    Quiz.includes(:target).find_each do |quiz|
      quiz.assignment = quiz.target.assignments.first
      quiz.save
    end


    assignment_evaluation_criterions = []
    assignment_prerequisites = []
    Target.joins(:assignments).includes(:assignments, :evaluation_criteria, :prerequisite_targets).find_each do |target|
      assignment_id = target.assignments.first.id
      target.evaluation_criteria.each do |evaluation_criteria|
        assignment_evaluation_criteria = {
          :assignment_id => assignment_id,
          :evaluation_criterion_id => evaluation_criteria.id
        }
        assignment_evaluation_criterions.append(assignment_evaluation_criteria)
      end
      target.prerequisite_targets.each do |prerequisite_target|
        assignment_prerequisite = {
          :assignment_id => assignment_id,
          :prerequisite_assignment_id => prerequisite_target.assignments.first.id
        }
        assignment_prerequisites.append(assignment_prerequisite)
      end
    end
    puts assignment_evaluation_criterions
    AssignmentEvaluationCriterion.insert_all(assignment_evaluation_criterions)
    AssignmentPrerequisite.insert_all(assignment_prerequisites)

  end
end
