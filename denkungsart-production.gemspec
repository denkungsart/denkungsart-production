
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "denkungsart/production/version"

Gem::Specification.new do |spec|
  spec.name          = "denkungsart-production"
  spec.version       = Denkungsart::Production::VERSION
  spec.authors       = ["Fabian Schwahn"]
  spec.email         = ["fabian.schwahn@gmail.com"]

  spec.summary       = "A few default initializers we use in all our apps."
  spec.homepage      = "https://github.com/denkungsart/denkungsart-production"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "lograge", "~> 0.10.0"
  spec.add_dependency "voight_kampff"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
end
