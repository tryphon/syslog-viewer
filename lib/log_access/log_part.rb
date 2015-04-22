module LogAccess
  class LogPart

    attr_accessor :file, :filter, :seek, :expected_first_line_tag

    def initialize(file = nil)
      self.file = file
    end

    def file
      @file ||= "/var/log/syslog"
    end

    def lines
      @lines ||= []
    end

    def add(line)
      if filter.nil? or line.match(/#{filter}/)
        lines << line
      end
    end

    attr_accessor :last_position, :first_line

    def first_line_tag
      Digest::SHA1.hexdigest(first_line) if first_line
    end

    def default_seek
      1024*1024
    end

    def seek_file(file)
      if seek and expected_first_line_tag
        if first_line_tag == expected_first_line_tag
          file.seek seek
          return
        end
      end

      unless default_seek > File.size(file)
        file.seek -default_seek, IO::SEEK_END
        file.gets
      else
        file.seek 0, IO::SEEK_SET
      end
    end

    def load
      File.open(file, 'r:UTF-8') do |f|
        self.first_line = f.gets

        seek_file f

        while line = f.gets
          add line.strip
        end

        self.last_position = f.pos
      end
    end

  end
end
