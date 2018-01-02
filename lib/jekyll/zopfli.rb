require "jekyll/zopfli/version"
require "jekyll/zopfli/compressor"

module Jekyll
  module Zopfli
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  if ENV["JEKYLL_ENV"] == "production"
    Jekyll::Zopfli::Compressor.new(site).compress
  end
end