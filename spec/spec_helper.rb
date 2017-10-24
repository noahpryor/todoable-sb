require 'todoable'
require 'rspec'
require 'webmock/rspec'
require 'support/mock_todoable'
require 'simplecov'
require 'coveralls'

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /todoable.teachable.tech/).to_rack(MockTodoable)
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
