require 'logger'

$logger = Logger.new(STDOUT)

logger_level = Logger::INFO
logger_level = Logger::WARN if ENV['QUIET'] == 'true'

# :nocov:
if [ ENV['DEBUG'], ENV['DOCKER_DEBUG'] ].include?('true')
  logger_level = Logger::DEBUG
  Docker.logger = $logger if ENV['DOCKER_DEBUG'] == 'true'
end
# :nocov:

$logger.level = logger_level
