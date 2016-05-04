module ActiveAdmin
  module TargetsOverviewHelper
    def assignees_list(target_template, status:)
      if target_template.founder_role?
        assignees(target_template, status).distinct.map { |f| link_to(f.fullname, admin_founder_path(f)) }
      else
        assignees(target_template, status).distinct.map { |s| link_to(s.product_name, admin_startup_path(s)) }
      end.join(', ').html_safe
    end

    def extended_scope?(status)
      status.to_sym == :extended
    end

    def effective_scope(status)
      extended_scope?(status) ? 'pending' : status
    end

    # returns founders or startups (as applicable) which have targets built from the specified template
    def assignees(target_template, status)
      assignees = if target_template.founder_role?
        Founder.find_by_batch(batch_selected)
          .joins(:targets)
          .where(targets: { target_template_id: target_template.id })
          .merge(Target.send(effective_scope(status)))
      else
        Startup
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
