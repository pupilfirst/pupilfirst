module ActiveAdmin
  module TargetsOverviewHelper
    def assignees_list(target_template, status:)
      if target_template.founder_role?
        assignees(target_template, status).distinct.map { |founder| link_to(founder.fullname, name_link(founder, target_template, status)) }
      else
        assignees(target_template, status).distinct.map { |startup| link_to(startup.product_name, name_link(startup, target_template, status)) }
      end.join(', ').html_safe
    end

    def name_link(assignee, template, status)
      status == :completed ? completion_event_path(assignee, template) : show_path(assignee)
    end

    def completion_event_path(assignee, template)
      admin_target_path assignee.targets.completed.where(target_template: template).last
    end

    def show_path(assignee)
      assignee.is_a?(Founder) ? admin_founder_path(assignee) : admin_startup_path(assignee)
    end

    def extended_scope?(status)
      status.to_sym == :extended
    end

    def effective_scope(status)
      extended_scope?(status) ? 'all' : status
    end

    # returns founders or startups (as applicable) which have targets built from the specified template
    def assignees(target_template, status)
      assignees = if target_template.founder_role?
        Founder.find_by_batch(batch_selected).not_dropped_out
          .joins(:targets)
          .where(targets: { target_template_id: target_template.id })
          .merge(Target.send(effective_scope(status)))
      else
        Startup.not_dropped_out
          .joins(:targets)
          .where(batch: batch_selected, targets: { target_template_id: target_template.id })
          .merge(Target.send(effective_scope(status)))
      end

      # extended targets are those with due date greater than their parent template
      assignees = assignees.where('targets.due_date > ?', target_template.due_date) if extended_scope?(status)
      assignees
    end
  end
end
