module Rack
  class Conneg
    class Static < Rack::Static

      # Initialize middleware for static file content negotiation
      #
      # @example
      #   use Rack::Conneg::Static, :urls => %w[ /css /images ], :root => 'public'
      #
      # @param [#call] app
      #   the Rack app to handle static requests
      # @param [Hash] options
      #   optional middleware configuration
      #
      # @return [Static]
      #   returns a new Static instance
      #
      # @api public
      def initialize(app, options = {})
        super
        @file_server = File.new(@file_server)
      end

    end
  end
end
