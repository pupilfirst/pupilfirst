module ActiveAdmin
  module TargetsOverviewHelper
    def assignees(target_template, status_scope)
      if target_template.founder_role?
        founders = Founder.find_by_batch(batch_selected)
          .joins(:targets)
          .where(targets: { target_template_id: target_template.id })
          .merge(Target.send(status_scope))
          .distinct

        assignees_list = founders.map{ |f| link_to(f.fullname, admin_founder_path(f)) }.join(', ')
      else
        startups = Startup
          .joins(:targets)
          .where(batch: batch_selected, targets: { target_template_id: target_template.id })
          .merge(Target.send(status_scope))
          .distinct

        assignees_list = startups.map{ |s| link_to(s.product_name, admin_startup_path(s)) }.join(', ')
      end

      assignees_list.html_safe
    end

    def assignees_with_extension(target_template)
      if target_template.founder_role?
        founders = Founder.find_by_batch(batch_selected)
          .joins(:targets)
          .where(targets: { target_template_id: target_template.id })
          .where('targets.due_date > ?', target_template.due_date )
          .merge(Target.pending)
          .distinct

        assignees_list = founders.map{ |f| link_to(f.fullname, admin_founder_path(f)) }.join(', ')
      else
        startups = Startup
          .joins(:targets)
          .where(batch: batch_selected, targets: { target_template_id: target_template.id })
          .where('targets.due_date > ?', target_template.due_date )
          .merge(Target.pending)
          .distinct

        assignees_list = startups.map{ |s| link_to(s.product_name, admin_startup_path(s)) }.join(', ')
      end

      assignees_list.html_safe
    end
  end
end
