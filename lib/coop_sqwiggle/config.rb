require 'yaml'
unless defined?(CONFIG_FILE)

  config_path = File.expand_path('../../../', __FILE__)
  CONFIG_FILE = YAML.load(File.read("#{config_path}/config.yml"))
  CONFIG_ENVIRONMENT = ENV['RUBY_ENV'].to_sym
  CONFIG = CONFIG_FILE[CONFIG_ENVIRONMENT]
end
