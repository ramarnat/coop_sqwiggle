require 'bundler/setup'
require "faraday"
require 'yaml'
require 'active_support/core_ext'
require 'json'
require 'logger'
require 'feedzirra'
require 'pry'
require 'pp'

module Sqwiggle
  # Set Version
  VERSION = '0.0.1'

  # Setup Logger
  Log = Logger.new(STDOUT)
  STDOUT.sync = true
  Log.level   = Logger::INFO
  #Log.level  = Logger::DEBUG

  Log.formatter = proc do |severity, datetime, progname, msg|
    "[#{severity}] #{datetime}:  #{msg}\n"
  end

end

lpath = 'coop_sqwiggle'
require_relative lpath + '/config'

# load the main api
require_relative lpath + '/sqwiggle_api'
require_relative lpath + '/coop_api'
require_relative lpath + '/raise_http_exception'

def logger
  Sqwiggle::Log
end
