module Rack
  class Conneg
    class Negotiator
      NOT_ACCEPTABLE = [
        406,
        { 'Content-Type' => 'text/plain', 'Content-Length' => '19' },
        "406 Not Acceptable\n",
      ].freeze

      def self.negotiate(app, env)
        negotiator = new(app, env)
        negotiator.pass? ? negotiator.pass : negotiator.call
      end

      def initialize(app, env)
        @app     = app
        @env     = env
        @request = Acceptable::Request.new(@env)
        @path    = Path.new(app.root, @request.path_info)
      end

      def pass?
        not @path.variants?
      end

      def pass(env = @env)
        @app.call(env)
      end

      def call
        variant  = select_variant
        response = variant ? serve_variant(variant.path_info) : NOT_ACCEPTABLE
        self.class.append_vary_header(response[1], 'Accept')
        response
      end

    private

      def select_variant
        variants = @path.variants
        variants[@request.preferred_media_from(*variants.keys)]
      end

      def serve_variant(path_info)
        status, headers, body = pass(@env.merge('PATH_INFO' => path_info))
        headers['Content-Location'] = path_info if (200..299).include?(status)
        [ status, headers, body ]
      end

      def self.append_vary_header(headers, *names)
        vary = split_header(headers['Vary'])
        return if vary.include?('*')
        headers['Vary'] = join_header(vary | names)
      end

      def self.split_header(header)
        header.to_s.delete(' ').split(',')
      end

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
