require "jekyll/zopfli/version"
require "jekyll/zopfli/compressor"

module Jekyll
  module Zopfli
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  Jekyll::Zopfli::Compressor.new(site).compress
end