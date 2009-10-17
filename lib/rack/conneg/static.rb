module Rack
  class Conneg
    class Static < Rack::Static
      def initialize(*)
        super
        @file_server = File.new(@file_server)
      end

    end
  end
end
