# Exercises: Hard 1.1

class SecretFile
  attr_reader :security_logger

  def initialize(secret_data)
    @data = secret_data
    @security_logger = SecurityLogger.new
  end

  def data
    security_logger.create_log_entry
    @data
  end
end

class SecurityLogger
  def create_log_entry
    puts "Security log created for this access attempt."
  end
end

my_secret = SecretFile.new("Aqua Cherry rocks.")

puts my_secret.data