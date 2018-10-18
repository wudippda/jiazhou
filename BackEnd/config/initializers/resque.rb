# config resque logger
Resque.logger.level = Logger::INFO
#Resque.logger.formatter = Resque::VeryVerboseFormatter.new
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))


rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque_config.yml')
Resque.redis = resque_config[rails_env]