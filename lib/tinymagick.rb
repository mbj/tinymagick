require 'open3'

module TinyMagick
  class Identification
    NAMES = %w(valid error status)

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    NAMES.each do |name|
      class_eval(<<-RUBY,__FILE__,__LINE__)
        def #{name}
          @attributes[#{name.inspect}]
        end
      RUBY
    end

    def valid?
      !!valid
    end
  end

  class << self
    def identify(path)
      err,out,status = run 'identify', '-ping', path
      Identification.new({
        'error' => err,
        'valid' => (status.zero? && err.empty?),
        'status' => status
      })
    end

    def run(command,*args)
      err=out=status=nil
      Open3.popen3(command,*args) do |stdin,stdout,stderr,waiter|
        stdin.close
        out = stdout.read
        err = stderr.read
        status = waiter.value.exitstatus
      end
      [err,out,status]
    end
  end
end
