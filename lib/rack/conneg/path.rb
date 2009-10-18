require 'pathname'

module Rack
  class Conneg
    class Path
      EXTENSION_REGEXP = Regexp.union(*Mime::MIME_TYPES.keys.map { |ext| ext[1..-1] }).freeze

      # Return the request path
      #
      # @return [String]
      #   the request path
      #
      # @api private
      attr_reader :path_info

      # Initialize a new Path
      #
      # @param [String, Pathname] root
      #   the server document root
      # @param [String] path_info
      #   the request path
      #
      # @return [Path]
      #   returns a new Path instance
      #
      # @api private
      def initialize(root, path_info)
        @root      = Pathname(root)
        @path_info = self.class.normalize_path_info(path_info)
        @path      = @root + @path_info[1..-1]
      end

      # Return the mime type for the request path
      #
      # @return [String, nil]
      #   the mime type if known
      #
      # @api private
      def mime_type
        Mime.mime_type(extname, nil)
      end

      # Test if there are variants for the request path
      #
      # @return [Boolean]
      #   true if there are variants
      #
      # @api private
      def variants?
        variants.any?
      end

      # Return the Hash of media types and variants
      #
      # @return [Hash]
      #   the variants for the request path
      #
      # @api private
      def variants
        return @variants if @variants
        variants = {}
        variant_paths.each { |path| variants[path.mime_type] = path }
        @variants = variants.freeze
      end

    private

      # Return the variant paths
      #
      # @return [Array<Path>]
      #   the variant paths
      #
      # @api private
      def variant_paths
        paths.select { |path| variant?(path) }
      end

      # Return all the paths in the request path directory
      #
      # @return [Array<Path>]
      #   the paths in the current directory
      #
      # @api private
      def paths
        directory.map do |path|
          self.class.new(@root, path.relative_path_from(@root))
        end
      end

      # Return all the children in the request path directory
      #
      # @return [Array<Pathname>]
      #   the children in the current directory
      #
      # @api private
      def directory
        @path.dirname.children
      rescue SystemCallError
        []
      end

      # Return the request path extension
      #
      # @return [String, nil]
      #   the request path extension
      #
      # @api private
      def extname
        @path.extname
      end

      # Test if the other Path is a variant
      #
      # @param [Path] other
      #   the other Path to test
      #
      # @return [Boolean]
      #   true if the other Path is a variant
      #
      # @api private
      def variant?(other)
        pattern === other.path_info
      end

      # Return a Regexp to match the request path and known extensions
      #
      # @return [Regexp]
      #   match the request path
      #
      # @api private
      def pattern
        @pattern ||= /\A#{Regexp.escape(path_info)}\.#{EXTENSION_REGEXP}\z/.freeze
      end

      # Normalize the request path info
      #
      # @return [String]
      #   the request path
      #
      # @api private
      def self.normalize_path_info(path_info)
        "/#{Utils.unescape(path_info.to_s).gsub(/\A\//, '')}"
      end

    end
  end
end
