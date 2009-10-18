module Rack
  class Conneg
    class Utils

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
