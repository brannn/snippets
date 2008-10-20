class SimpleLogger
  attr_accessor :level, :stamp

  ERROR = 1
  WARNING = 2
  INFO = 3
    
  def initialize
    @log = File.open("log.txt", "w")
    @level =  WARNING
    @stamp = Time.now.strftime('%Y-%d-%b %H:%M:%S')
  end

  def error(msg)
    @log.puts("#{stamp} " + "ERR: " + msg)
    @log.flush
  end

  def warning(msg)
    @log.puts("#{stamp} " + "WARN: " + msg) if @level >=  WARNING
    @log.flush
  end

  def info(msg)
    @log.puts("#{stamp} " + "INFO: " + msg) if @level >=  INFO
    @log.flush
  end

end
