# frozen_string_literal: true

require 'jekyll/zopfli/config'
require 'zopfli'

module Jekyll
  ##
  # The main namespace for +Jekyll::Zopfli+. Includes the +Compressor+ module
  # which is used to map over files, either using an instance of +Jekyll::Site+
  # or a directory path, and compress them using Zopfli.
  module Zopfli
    ##
    # The module that does the compressing using Zopfli.
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
          next unless regenerate? file.destination(site.dest), site

          compress_file(
            file.destination(site.dest),
            extensions: zippable_extensions(site),
            replace_file: replace_files(site)
          )
        end
      end

      ##
      # Takes a directory path and maps over the files within compressing them
      # in place.
      #
      # @example
      #     Jekyll::Zopfli::Compressor.compress_directory("~/blog/_site", site)
      #
      # @param dir [Pathname, String] The path to a directory of files ready for
      #   compression.
      # @param site [Jekyll::Site] An instance of the `Jekyll::Site` used for
      #   config.
      #
      # @return void
      def self.compress_directory(dir, site)
        extensions = zippable_extensions(site).join(',')
        files = Dir.glob(dir + "/**/*{#{extensions}}")
        files.each do |file|
          next unless regenerate? file, site

          compress_file(
            file,
            extensions: zippable_extensions(site),
            replace_file: replace_files(site)
          )
        end
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
      # @param replace_file [Boolean] Whether the original file should be
      #    replaced or written alongside the original with a `.gz` extension
      #
      # @return void
      def self.compress_file(file_name, extensions: [], replace_file: false)
        return unless extensions.include?(File.extname(file_name))
        zipped = replace_file ? file_name : "#{file_name}.gz"
        contents = ::Zopfli.deflate(File.binread(file_name), format: :gzip)
        File.open(zipped, "w+") do |file|
          file << contents
        end
        File.utime(File.atime(file_name), File.mtime(file_name), zipped)
      end

      private

      def self.zippable_extensions(site)
        site.config['zopfli'] && site.config['zopfli']['extensions'] || Jekyll::Zopfli::DEFAULT_CONFIG['extensions']
      end

      def self.replace_files(site)
        replace_files = site.config.dig('zopfli', 'replace_files')
        replace_files.nil? ? Jekyll::Zopfli::DEFAULT_CONFIG['replace_files'] : replace_files
      end

      def self.zipped(file_name, replace_file)
        replace_file ? file_name : "#{file_name}.gz"
      end

      # Compresses the file if the site is built incrementally and the
      # source was modified or the compressed file doesn't exist
      def self.regenerate?(file, site)
        zipped = zipped(file, replace_files(site))

        # Definitely generate the file if it doesn't exist yet.
        return true unless File.exist? zipped
        # If we are replacing files and this file is not a gzip file, then it
        # has been edited so we need to re-gzip it in place.
        return !is_already_gzipped?(file) if replace_files(site)

        # If the modified time of the new file is greater than the modified time
        # of the old file, then we need to regenerate.
        File.mtime(file) > File.mtime(zipped)
      end

      # First two bytes of a gzipped file are 1f and 8b. This tests for those
      # bytes.
      def self.is_already_gzipped?(file)
        ["1f", "8b"] == File.read(file, 2).unpack("H2H2")
      end
    end
  end
end
