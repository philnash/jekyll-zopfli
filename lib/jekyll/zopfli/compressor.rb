require "zopfli"

module Jekyll
  module Zopfli
    class Compressor
      ZIPPABLE_EXTENSIONS = [
        '.html',
        '.css',
        '.js',
        '.txt',
        '.ttf',
        '.atom',
        '.stl',
        '.xml',
        '.svg',
        '.eot'
      ]

      attr_reader :site

      def initialize(site)
        @site = site
      end

      def compress_file(file_name)
        return unless ZIPPABLE_EXTENSIONS.include?(File.extname(file_name))
        zipped = "#{file_name}.gz"
        contents = ::Zopfli.deflate(File.read(file_name), format: :gzip)
        File.open(zipped, "w+") do |file|
          file << contents
        end
        File.utime(File.atime(file_name), File.mtime(file_name), zipped)
      end

      def compress
        site.each_site_file do |file|
          compress_file(file.destination(site.dest))
        end
      end
    end
  end
end 