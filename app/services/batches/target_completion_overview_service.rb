module Batches
  # This generates an overview of completion status for all targets for all startups in a batch. The mail_overview
  # method emails the overview as simplified CSV (attachment) to a supplied address.
  class TargetCompletionOverviewService
    include RoutesResolvable

    def initialize(batch)
      @batch = batch
    end

    def overview
      @overview ||= startups.each_with_object({}) do |startup, result|
        result[startup] = target_completion_statuses_for(startup)
      end
    end

    def overview_csv
      CSV.generate do |csv|
        csv << ['Startups'] + targets.map(&:title)

        startups.each do |startup|
          row = [startup.product_name]

          targets.each do |target|
            status = overview[startup][target]
            row << csv_completion_status(status, target)
          end

          csv << row
        end
      end
    end

    def mail_overview(email_address)
      AdminUserMailer.target_completion_overview(email_address, overview_csv, filename, @batch.batch_number).deliver_now
    end

    private

    def filename
      timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
      "target_completion_overview_#{timestamp}.csv"
    end

    def csv_completion_status(status, target)
      if target.founder_role?
        completed = status.values.count { |v| v == Targets::StatusService::STATUS_COMPLETE }
        "#{completed} / #{status.values.length} completed"
      else
        (status == Targets::StatusService::STATUS_COMPLETE ? 'Completed' : 'Not completed')
      end
    end

    def target_completion_statuses_for(startup)
      targets.each_with_object({}) do |target, statuses|
        statuses[target] = startup_status_for_target(startup, target)
      end
    end

    def startup_status_for_target(startup, target)
      if target.founder_role?
        startup.founders.each_with_object({}) do |founder, founder_statuses|
          founder_statuses[founder] = target.status(founder)
        end
      else
        target.status(startup.admin)
      end
    end

    def targets
      @targets ||= @batch.targets
    end

    def startups
      @startup ||= @batch.startups
    end
  end
end
