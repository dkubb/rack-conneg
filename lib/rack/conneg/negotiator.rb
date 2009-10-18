module Rack
  class Conneg
    class Negotiator

      # Negotiate a response using the request headers
      #
      # @param [#call] app
      #   the Rack app to handle static requests
      # @param [Hash] env
      #   the Rack request environment
      #
      # @return [Array(Integer, Hash, #each)]
      #   returns a Rack response
      #
      # @api private
      def self.negotiate(app, env)
        negotiator = new(app, env)
        negotiator.pass? ? negotiator.pass : negotiator.call
      end

      # Initialize a new Negotiator
      #
      # @param [#call] app
      #   the Rack app to handle static requests
      # @param [Hash] env
      #   the Rack request environment
      #
      # @return [Negotiator]
      #   returns a new Negotiator instance
      #
      # @api private
      def initialize(app, env)
        @app     = app
        @request = Acceptable::Request.new(env)
        @path    = Path.new(app.root, @request.path_info)
      end

      # Test if the request should be passed to the next Rack app
      #
      # @return [Boolean]
      #   true if the request should be passed through
      #
      # @api private
      def pass?
        not @path.exist? ? @path.mime_type.nil? : @path.variants?
      end

      # The response from the next Rack app
      #
      # @param [Hash] env
      #   optional Rack request environment
      #
      # @return [Array(Integer, Hash, #each)]
      #   returns a Rack response
      #
      # @api private
      def pass(env = @request.env)
        @app.call(env)
      end

      # Negotiate the optimal response based on client preferences
      #
      # @return [Array(Integer, Hash, #each)]
      #   returns a negotiated Rack response
      #
      # @api private
      def call
        path     = select_variant
        response = path && path.mime_type ? serve_path(path) : NOT_ACCEPTABLE
        Utils.append_vary_header(response[1], 'Accept')
        response
      end

    private

      # Select the best variant based on client preferences
      #
      # @return [Path, nil]
      #   the negotiated variant, nil if none available
      #
      # @api private
      def select_variant
        variants = @path.variants
        variants[@request.preferred_media_from(*variants.keys)]
      end

      # Serve the path to the client
      #
      # @param [Path] path
      #   the path to serve
      #
      # @return [Array(Integer, Hash, #each)]
      #   returns a negotiated Rack response
      #
      # @api private
      def serve_path(path)
        path_info = path.path_info
        status, headers, body = pass(@request.env.merge('PATH_INFO' => path_info))
        headers['Content-Location'] = path_info if (200..299).include?(status)
        [ status, headers, body ]
      end

    end
  end
end
