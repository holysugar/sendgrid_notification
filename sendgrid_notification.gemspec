$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sendgrid_notification/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sendgrid_notification"
  s.version     = SendgridNotification::VERSION
  s.authors     = ["HORII Keima"]
  s.email       = ["holysugar@gmail.com"]
  s.homepage    = ""
  s.summary     = "notification mail sender via sendgrid API"
  s.description = "notification mail sender via sendgrid API"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.2"
  s.add_dependency "sendgrid-ruby"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest-power_assert"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "minitest-rg"
end
