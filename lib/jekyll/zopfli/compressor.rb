require 'jekyll/zopfli/config'
require 'zopfli'

module Jekyll
  module Zopfli
    module Compressor
      ##
      # Takes an instance of +Jekyll::Site+ and maps over the site files
      # compressing them in the destination directory.
      # @example
      #     site = Jekyll::Site.new(site_config)
      #     Jekyll::Zopfli::Compressor.compress_site(site)
      #
      # @param site [Jekyll::Site] A Jekyll::Site object that has generated its
      #   site files ready for compression.
      #
      # @return void
      def self.compress_site(site)
        site.each_site_file do |file|
          compress_file(file.destination(site.dest), zippable_extensions(site))
        end
      end

      ##
      # Takes a directory path and maps over the files within compressing them
      # in place.
      #
      # @example
      #     Jekyll::Zopfli::Compressor.compress_directory("~/blog/_site")
      #
      # @param dir [Pathname, String] The path to a directory of files ready for
      #   compression.
      # @param site [Jekyll::Site] An instance of the `Jekyll::Site` used for
      #   config.
      #
      # @return void
      def self.compress_directory(dir, site)
        extensions = zippable_extensions(site).join(',')
        files = Dir.glob(dir + "**/*{#{extensions}")
        files.each { |file| compress_file(file, extensions) }
      end

      ##
      # Takes a file name and an array of extensions. If the file name extension
      # matches one of the extensions in the array then the file is loaded and
      # compressed using Zopfli, outputting the gzipped file under the name of
      # the original file with an extra .gz extension.
      #
      # @example
      #     Jekyll::Zopfli::Compressor.compress_file("~/blog/_site/index.html", ['.html')
      #
      # @param file_name [String] The file name of the file we want to compress
      # @param extensions [Array<String>] The extensions of files that will be
      #    compressed.
      #
      # @return void
      def self.compress_file(file_name, extensions)
        return unless extensions.include?(File.extname(file_name))
        zipped = "#{file_name}.gz"
        contents = ::Zopfli.deflate(File.read(file_name), format: :gzip)
        File.open(zipped, "w+") do |file|
          file << contents
        end
        File.utime(File.atime(file_name), File.mtime(file_name), zipped)
      end

      private

      def self.zippable_extensions(site)
        site.config['zopfli'] && site.config['zopfli']['extensions'] || Jekyll::Zopfli::DEFAULT_CONFIG['extensions']
      end
    end
  end
end