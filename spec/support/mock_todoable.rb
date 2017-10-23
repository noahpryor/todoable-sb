# spec/support/mock_todoable.rb

require 'sinatra/base'

class MockTodoable < Sinatra::Base

  

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
