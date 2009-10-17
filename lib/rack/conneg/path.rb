require 'pathname'

module Rack
  class Conneg
    class Path
      EXTENSION_REGEXP = Regexp.union(*Mime::MIME_TYPES.keys.map { |ext| ext[1..-1] }).freeze

      attr_reader :path_info

      def initialize(root, path_info)
        @root      = Pathname(root)
        @path_info = self.class.normalize_path_info(path_info)
        @path      = @root + @path_info[1..-1]
      end

      def mime_type
        Mime.mime_type(extname, nil)
      end

      def exist?
        @path.exist?
      end

      def variants?
        variants.any?
      end

      def variants
        return @variants if @variants
        variants = {}
        variant_paths.each { |path| variants[path.mime_type] = path }
        @variants = variants.freeze
      end

    private

      def variant_paths
        paths.select { |path| variant?(path) && path.exist? }
      rescue SystemCallError
        []
      end

      def paths
        directory.map do |path|
          self.class.new(@root, path.relative_path_from(@root))
        end
      end

      def directory
        @path.dirname.children
      end

      def extname
        @path.extname
      end

      def variant?(other)
        pattern === other.path_info
      end

      def pattern
        @pattern ||= /\A#{Regexp.escape(path_info)}\.#{EXTENSION_REGEXP}\z/.freeze
      end

      def self.normalize_path_info(path_info)
        "/#{Utils.unescape(path_info.to_s).gsub(/\A\//, '')}"
      end

    end
  end
end
