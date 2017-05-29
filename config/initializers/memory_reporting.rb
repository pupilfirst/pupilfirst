if ENV['MEMORY_REPORTING']
  Rails.logger.debug 'Setting up memory reporting...'

  Thread.new do
    report_path = File.absolute_path(Rails.root.join('memory_report.csv'))
    Rails.logger.debug "Writing report to: #{report_path}"
    `echo "#{%w[time rss heap_live_slots].join(',')}" > #{report_path}`

    loop do
      pid = Process.pid
      rss = `ps -eo pid,rss | grep #{pid} | awk '{print $2}'`.to_i
      heap_live_slots = GC.stat[:heap_live_slots]
      Rails.logger.debug "MEMORY[#{pid}]: rss: #{rss}, live objects #{heap_live_slots}"
      `echo "#{[Time.now.to_i, rss, heap_live_slots].join(',')}" >> #{report_path}`

      sleep 5
    end
  end
end
