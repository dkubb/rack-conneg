module Rack
  class Conneg
    class File
      def initialize(file_server)
        @file_server = file_server
      end

      def call(env)
        Negotiator.negotiate(@file_server, env)
      end

    end
  end
end
