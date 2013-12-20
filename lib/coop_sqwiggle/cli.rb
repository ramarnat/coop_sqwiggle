require_relative '../coop_sqwiggle.rb'
require 'pry'
module Sqwiggle

  logger.level = Logger::INFO

  class CLI < Thor
    class_option :debug, :aliases => "-D", :type => :boolean, :desc => "debug",
                 :default => false

    def initialize(*args)
      super
      set_debug
      @sqwiggle_api = Sqwiggle::API.new
      @coop_api = Coop::API.new
    end

    no_commands do
      def set_debug
        if options.debug?
          logger.level = Logger::DEBUG
        else
          logger.level = Logger::INFO
        end
      end
    end

    desc "coop_feed", "Show the coop feed."
    def coop_feed
      note_exported = {}
      while 1==1 do
        entries = @coop_api.response("/groups/10707/#{Time.now.strftime('%Y%m%d')}")
        entries.each do |entry|
#          binding.pry
          text = nil
          if entry['type'] == "Note" && note_exported[entry['id']].nil?
            text = "#{entry['user']['name']}: #{entry['text']}"
          elsif entry['type'] == "DayEntry" &&
                entry['timer_started_at'].nil?
            text = "#{entry['user']['name']}\n [#{entry['hours']}] #{entry['text']} in #{entry['client']}/#{entry['project']} (#{entry['task']})"
          elsif entry['type'] == "DayEntry" &&
                !entry['timer_started_at'].nil?
            text = "#{entry['user']['name']}\n [#{entry['hours']}] #{entry['text']} in #{entry['client']}/#{entry['project']} (#{entry['task']})"
          end

          if text
            h = {}
            r = nil
            if note_exported[entry['id']]
              h['text'] = text
              r = @sqwiggle_api.conn.put do |req|
                req.url "/messages/#{note_exported[entry['id']]}"
                req.headers['Content-Type'] = 'application/json'
                req.body = h.to_json
              end
            else
              h['text'] = text
              h['room_id'] = CONFIG['sqwiggle_room_id']

              r = @sqwiggle_api.conn.post do |req|
                req.url "/messages"
                req.headers['Content-Type'] = 'application/json'
                req.body = h.to_json
              end
            end

            body = JSON.parse(r.body)
            note_exported[entry['id']] = body['id']
          end
        end
        sleep 60
      end
    end
  end
end

Sqwiggle::CLI.start(ARGV)



