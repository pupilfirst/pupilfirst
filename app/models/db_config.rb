class DbConfig < ActiveRecord::Base

  VARS = {
    stats_application: "Startup Application's",
    stats_startup_supported: "Startup's Supported",
    student_startups: "Student Startup's",
    regular_incubatees: "Regular Incubatee's",
    documents_submition_date: "Document's Submition Date",
    documents_submition_time: "Document's Submition Time",
    featured_startup_id: 'Featured Startup ID',
    sms_statistics_all: 'SMS Statistics All',
    sms_statistics_total: 'SMS Statistics Total',
    sms_statistics_visakhapatnam: 'SMS Statistics Visakhapatnam',
    sms_statistics_kochi: 'SMS Statistics Kochi',
    feature_faculty_page: '(dev) Toggle Faculty Page'
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

  def self.featured_startup
    Startup.find(find_by_key(:featured_startup_id).value) rescue nil
  end

  # To use feature flags, add a key with name 'feature_FEATURE_NAME' and store JSON value with key 'users', or 'active'.
  # 'users' key should contain an array of allowed user e-mails, OR 'active' should be set to affect all users.
  def self.feature_active?(key, user=nil)
    feature = where(key: "feature_#{key}").first

    return false unless feature

    feature_value = begin
      JSON.load(feature[:value]).with_indifferent_access
    rescue JSON::ParserError
      return false
    end

    if user
      feature_value[:users].include? user.email
    else
      feature_value[:active].present?
    end
  end
end
