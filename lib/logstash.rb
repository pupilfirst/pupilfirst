class Logstash
  include Singleton

  attr_reader :logstash_logger

  def initialize
    @logstash_logger = LogStashLogger.new(type: :stdout)
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
