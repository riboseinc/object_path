
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "object_path/version"

Gem::Specification.new do |spec|
  spec.name          = "object_path"
  spec.version       = ObjectPath::VERSION
  spec.authors       = ["Ribose Inc"]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Generate path or URL for an ActiveRecord object."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/riboseinc/object_path"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
