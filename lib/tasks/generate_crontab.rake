desc "Generate crontab file for use by supercronic"
task :generate_crontab do
  lines =
    %w[cleanup daily_digest notify_and_delete_inactive_users].map do |task|
      schedule = ENV["SCHEDULE_#{task.upcase}"] || "0 0 0 * * * *"
      "#{schedule} cd /app && bundle exec rake #{task}"
    end

  crontab_path = Rails.root.join("crontab")

  File.write(crontab_path, lines.join("\n\n") + "\n")
end
