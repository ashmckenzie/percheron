require 'logger'

$logger = Logger.new(STDOUT)

logger_level = Logger::INFO
logger_level = Logger::WARN if ENV['QUIET'] == 'true'

if ENV['DEBUG'] == 'true' || ENV['DOCKER_DEBUG'] == 'true'
  logger_level = Logger::DEBUG
  Docker.logger = $logger if ENV['DOCKER_DEBUG'] == 'true'
end

$logger.level = logger_level
