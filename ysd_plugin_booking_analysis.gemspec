
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ysd_plugin_booking_analysis/version"

Gem::Specification.new do |spec|
  spec.name          = "ysd_plugin_booking_analysis"
  spec.version       = YsdPluginBookingAnalysis::VERSION
  spec.authors       = ["Yurak Sisa"]
  spec.email         = ["yurak.sisa.dream@gmail.com"]

  spec.summary       = %q{Booking analysis plugin}
  spec.description   = %q{Booking analysis plugin}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
