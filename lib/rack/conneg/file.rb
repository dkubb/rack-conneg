module Rack
  class Conneg
    class File

      # Initialize a new File
      #
      # @param [#call] app
      #   the Rack app to handle static requests
      #
      # @return [File]
      #   returns a new File instance
      #
      # @api private
      def initialize(file_server)
        @file_server = file_server
      end

      # Negotiate a response using the request headers
      #
      # @param [Hash] env
      #   the Rack request environment
      #
      # @return [Array(Integer, Hash, #each)]
      #   returns a Rack response
      #
      # @api private
      def call(env)
        Negotiator.negotiate(@file_server, env)
      end

    end
  end
end
