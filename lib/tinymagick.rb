require 'open3'

module TinyMagick
  FORMAT,NAMES = begin
    names_and_formats = (<<-RAW_FORMAT
      %b   original file size of image file                      :size
      %c   comment property                                      :comment
      %d   directory path                                        :directory
      %e   filename extension or suffix                          :ext
      %f   filename (including suffix)                           :filename
      %g   page geometry   ( = %Wx%H%X%Y )                       :geometry
      %h   current image height in pixels                        :height
      %i   input filename (full path)                            :input_filename
      %k   number of unique colors                               :number_of_unique_colors
      %l   label property                                        :label
      %m   magick format used during read                        :magick_format
      %n   number of images in sequence                          :number_of_images
      %o   output filename                                       :output_filename
      %p   index of image in sequence                            :index
      %q   quantum depth (compile-time constant)                 :quantum_depth
      %r   image class and colorspace                            :colorspace
      %s   scene number (from input unless re-assigned)          :scene_number
      %t   top of filename (excluding suffix)                    :top_of_filename
      %u   unique temporary filename                             :temporary_filename
      %w   current width in pixels                               :width
      %x   x resolution                                          :x_resolution
      %y   y resolution                                          :y_resolution
      %z   image depth (as read in)                              :image_depth
      %A   image transparency channel enabled (true/false)       :transparency_enabled
      %C   image compression type                                :compression_type
      %D   image dispose method                                  :dispose_method
      %G   image size ( = %wx%h )                                :image_size
      %H   page (canvas) height                                  :page_canvas_height
      %O   page (canvas) offset ( = %X%Y )                       :page_canvas_offset
      %P   page (canvas) size ( = %Wx%H )                        :page_canvas_size
      %Q   image compression quality                             :compression_quality
      %S   ?? scenes ??                                          :scenes
      %T   image time delay                                      :time_delay
      %W   page (canvas) width                                   :page_canvas_width
      %X   page (canvas) x offset (including sign)               :page_canvas_x_offset
      %Y   page (canvas) y offset (including sign)               :page_canvas_y_offset
      %@   bounding box                                          :bounding_box
      %#   signature                                             :signature
      %%   a percent sign 
      \n   newline
      \r   carriage return
    RAW_FORMAT
    ).split("\n").map do |line|
      if line =~ /(%.)(?:.+?):([a-z_]+)/
        [$2,$1]
      else
        nil
      end
    end.compact
    [
      "#{names_and_formats.map { |name,format| "#{name}: #{format}" }.join("\n")}\n",
      names_and_formats.map { |name,format| name } + %w(error valid status)
    ]
  end
  
  class Identification
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
      err,out,status = run 'identify', '-ping', '-format', FORMAT, path
      attributes = out.split("\n").inject({}) do |acc,line|
        if line =~ /\A([a-z_]+): (.*)\Z/
          key,value = $1,$2
          value = case key
          when 'size' then value =~ /\A([0-9]+)B\Z/ ? $1.to_i : raise("invalid size: #{value.inspect}")
          when 'dispose_method','compression_type' then value == 'Undefined' ? nil : value
          when 'transparency_enabled' then 
            case value
            when 'True' then true
            when 'False' then false
            else
              raise("invalud boolean for #{key}: #{value.inspect}")
            end
          when 'height', 'width', 'number_of_unique_colors', 'number_of_images','quantum_depth','scene_number','image_depth','page_canvas_height','page_canvas_width' then
            value =~ /\A([0-9]+)\Z/ ? $1.to_i : raise("invalid #{key.inspect}: #{value.inspect}")
          else value
          end
          acc[key]=value
        end
        acc
      end
      Identification.new(attributes.merge({
        'error' => err.empty? ? nil : err,
        'valid' => (status.zero? && err.empty?),
        'status' => status
      }))
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
