# spec/support/mock_todoable.rb

require 'sinatra/base'

class MockTodoable < Sinatra::Base

  post '/api/authenticate' do
    content_type :json
    status 200
    { token: "a-valid-token" }.to_json
  end

  get '/api/lists' do
    json_response(200, 'get_lists.json')
  end

  get '/api/lists/:list_id' do
    json_response(200, 'get_list.json')
  end

  post '/api/lists' do
    status 201
    response.headers['Location'] = "http://todoable.teachable.tech/api/lists/this-is-a-list-id"
  end

  patch '/api/lists/:id' do
    status 201
    response.headers['Location'] = "http://todoable.teachable.tech/api/lists/this-is-a-list-id"
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
