require 'faker'

class LogFabricator

  attr_accessor :line_count, :size, :start_time, :append

  def initialize(options = {})
    options = {
      :line_count => 1000
    }.merge options

    options.each do |k,v|
      send "#{k}=", v
    end
  end

  def start_time
    @start_time ||= Time.now - (3600 * 24)
  end

  def file
    "tmp/log"
  end

  def create
    time_step = 100
    added_lines = 0

    open_mode = "w"
    open_mode += "a" if append

    File.open(file, open_mode) do |f|
      time = start_time

      while (line_count and added_lines < line_count) or (size and f.pos < size)
        f.puts [time.strftime("%B %d %H:%M:%S"), hostname, process, Faker::Lorem.sentence].join(' ')
        time += rand(100)
        added_lines += 1
      end
    end

    file
  end

  def hostname
    "host#{rand(3)}"
  end

  def process_names
    @process_names ||= {}
  end

  def process
    process_id = rand(10)
    process_names[process_id] ||=
      begin
        pid = rand(10000)
        pid_part = "[#{pid}]" unless pid % 5 == 0
        "process#{process_id + 1}#{pid_part}:"
      end
  end


end
