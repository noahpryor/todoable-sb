require "todoable"
require "rspec"
require "webmock/rspec"
require "support/mock_todoable"

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /todoable.teachable.tech/).to_rack(MockTodoable)
  end
end
