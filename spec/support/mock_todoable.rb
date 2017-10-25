# spec/support/mock_todoable.rb

require 'sinatra/base'

class MockTodoable < Sinatra::Base
  post '/api/authenticate' do
    content_type :json
    status 200
    { token: 'a-valid-token' }.to_json
  end

  get '/api/lists' do
    json_response(200, 'get_lists.json')
  end

  get '/api/lists/:list_id' do
    json_response(200, 'get_list.json')
  end

  post '/api/lists' do
    status 201
    json_response(201, 'create_list.json')
  end

  patch '/api/lists/:id' do
    status 201
    response.headers['Location'] = 'http://todoable.teachable.tech/api/lists/this-is-a-list-id'
  end

  delete '/api/lists/:id' do
    status 204
  end

  post '/api/lists/:id/items' do
    status 201
    response.headers['Location'] = 'http://todoable.teachable.tech/api/lists/this-is-a-list-id/items/this-is-a-list-item-id'
  end

  put '/api/lists/:id/items/:item_id/finish' do
    status 200
  end

  delete '/api/lists/:list_id/items/:id' do
    status 204
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end
