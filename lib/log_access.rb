require 'logger'
require 'digest'
require 'singleton'

require 'log_access/log_part'

module LogAccess
  class Application
    include Singleton

    def config_file
      @config_file ||= File.expand_path("../../config/config.rb", __FILE__)
    end

    def setup
      require config_file if File.exists? config_file
      self
    end

    attr_accessor :logger
    def logger
      @logger ||= Logger.new $stdout
    end

    def default_seek
      1024*1024
    end

    def call(env)
      req = Rack::Request.new(env)

      log_part = LogPart.new
      log_part.filter = req.params["filter"]
      log_part.seek = req.params["seek"].to_i
      log_part.expected_first_line_tag = req.params["first"]

      logger.debug log_part.inspect

      log_part.load

      headers = {
        "Content-Type" => "text/plain",
        "X-LogAccess-seek" => log_part.last_position.to_s,
        "X-LogAccess-first" => log_part.first_line_tag
      }

      [ 200, headers, log_part.lines.join("\n") + "\n" ]
    rescue Exception => e
      logger.error e
      [ 500, {}, "Internal error: #{e.to_s}" ]
    end
  end
end
