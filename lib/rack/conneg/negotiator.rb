module Rack
  class Conneg
    class Negotiator
      NOT_ACCEPTABLE = [
        406,
        { 'Content-Type' => 'text/plain', 'Content-Length' => '19' },
        "406 Not Acceptable\n",
      ].freeze

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
        not @path.variants?
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
        variant  = select_variant
        response = variant ? serve_path(variant) : NOT_ACCEPTABLE
        self.class.append_vary_header(response[1], 'Accept')
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

      # Append client header names used to negotiate the response to Vary
      #
      # @param [Hash] headers
      #   the Rack response headers
      # @param [Array<String>] *names
      #   the client headers used to negotiate the response
      #
      # @return [undefined]
      #
      # @api private
      def self.append_vary_header(headers, *names)
        vary = split_header(headers['Vary'])
        return if vary.include?('*')
        headers['Vary'] = join_header(vary | names)
      end

      # Split the header value into an Array
      #
      # @param [#to_s] header
      #   the header value to split
      #
      # @return [Array<String>]
      #   the header values
      #
      # @api private
      def self.split_header(header)
        header.to_s.delete(' ').split(',')
      end

      # Join the header values into a String
      #
      # @param [Array<String>] values
      #   the header values to join
      #
      # @return [String]
      #   the header value
      #
      # @api private
      def self.join_header(values)
        values.join(',')
      end

      class << self
        private :split_header
        private :join_header
      end

    end
  end
end
