# frozen_string_literal: true

module Jekyll
  module Zopfli
    DEFAULT_CONFIG = {
      'extensions' => [
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
      ].freeze
    }.freeze
  end
end