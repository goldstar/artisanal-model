lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "artisanal/model/version"

Gem::Specification.new do |spec|
  spec.name          = "artisanal-model"
  spec.version       = Artisanal::Model::VERSION
  spec.authors       = ["Jared Hoyt, Matthew Peychich"]
  spec.email         = ["jaredhoyt@gmail.com, mpeychich@mac.com"]

  spec.summary       = %q{A light attributes wrapper for dry-initializer}
  spec.description   = %q{A light attributes wrapper for dry-initializer}
  spec.homepage      = "https://github.com/goldstar/artisanal-model"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_runtime_dependency "dry-initializer", ">= 2.5.0"

  spec.add_development_dependency "dry-types", ">= 0.13.3"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rb-readline"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rspec-its", "~> 1.2"
end
