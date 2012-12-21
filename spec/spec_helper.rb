$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

MODELS = File.join(File.dirname(__FILE__), "models")
SUPPORT = File.join(File.dirname(__FILE__), "support")
$LOAD_PATH.unshift(MODELS)
$LOAD_PATH.unshift(SUPPORT)

require "mongoid"
require "rspec"
require "mongoid_spacial"
require "mocha/setup"
require "mocha/api"

LOGGER = Logger.new($stdout)

if RUBY_VERSION >= '1.9.2'
  YAML::ENGINE.yamler = 'syck'
end

Mongoid.configure do |config|
  name = "mongoid_spacial_test"
  config.connect_to(name)
  config.allow_dynamic_fields = true
end

Dir[ File.join(MODELS, "*.rb") ].sort.each { |file| require File.basename(file) }
Dir[ File.join(SUPPORT, "*.rb") ].each { |file| require File.basename(file) }

RSpec.configure do |config|
  config.mock_with(:mocha)

  config.after(:suite) { Mongoid.purge! }

  # We filter out the specs that require authentication if the database has not
  # had the mongoid user set up properly.
  user_configured = Support::Authentication.configured?
  warn(Support::Authentication.message) unless user_configured

  config.filter_run_excluding(:config => lambda { |value|
    return true if value == :user && !user_configured
  })
end
