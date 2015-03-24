class Logstash
  include Singleton

  attr_reader :logstash_logger

  def initialize
    @logstash_logger = if Rails.env.test?
      Logger.new '/dev/null'
    else
      LogStashLogger.new(type: :stdout)
    end
  end

  def self.llog
    instance.logstash_logger
  end
end

module Rails
  def self.llog
    Logstash.llog
  end
end
