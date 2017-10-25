# frozen_string_literal: true

require 'todoable'
require 'rspec'
require 'webmock/rspec'
require 'support/mock_todoable'
require 'timecop'
require 'simplecov'
require 'coveralls'

RSpec.configure do |config|
  config.before do
    stub_request(:any, /todoable.teachable.tech/).to_rack(MockTodoable)
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)

BASE_URL = 'http://todoable.teachable.tech/api/'.freeze
