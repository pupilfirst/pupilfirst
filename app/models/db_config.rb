class DbConfig < ActiveRecord::Base

  VARS = {
    stats_application: "Startup Application's",
    stats_startup_supported: "Startup's Supported",
    student_startups: "Student Startup's",
    regular_incubatees: "Regular Incubatee's",
    documents_submition_date: "Document's Submition Date",
    documents_submition_time: "Document's Submition Time"
  }

  def self.stats_application
    find_by_key(:stats_application).value rescue nil
  end

  def self.stats_startup_supported
    find_by_key(:stats_startup_supported).value rescue nil
  end

  def self.student_startups
    find_by_key(:student_startups).value rescue nil
  end

  def self.regular_incubatees
    find_by_key(:regular_incubatees).value rescue nil
  end

  def self.documents_submition_date
    find_by_key(:documents_submition_date).value rescue nil
  end

  def self.documents_submition_time
    find_by_key(:documents_submition_time).value rescue nil
  end
end
