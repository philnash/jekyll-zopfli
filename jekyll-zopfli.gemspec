
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/zopfli/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-zopfli"
  spec.version       = Jekyll::Zopfli::VERSION
  spec.authors       = ["Phil Nash"]
  spec.email         = ["philnash@gmail.com"]

  spec.summary       = "Generate gzipped assets and files for your Jekyll site at build time using Zopfli compression."
  spec.description   = "Generate gzipped assets and files for your Jekyll site at build time using Zopfli compression."
  spec.homepage      = "https://github.com/philnash/jekyll-zopfli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", "~> 3.0"
  spec.add_dependency "zopfli", "~> 0.0.7"

  spec.add_development_dependency "bundler", ">= 1.16", "< 3.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.15.1"
end
