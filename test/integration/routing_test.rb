require_relative '../test_helper'

class RoutingTest < Redmine::RoutingTest
  test 'routing rates' do
    should_route 'GET /rates'        => 'rates#index'
    should_route 'GET /rates/new'    => 'rates#new'
    should_route 'GET /rates/1'      => 'rates#show', id: '1'
    should_route 'GET /rates/1/edit' => 'rates#edit', id: '1'

    should_route 'POST /rates'       => 'rates#create'
    should_route 'PUT /rates/1'      => 'rates#update', id: '1'
    should_route 'DELETE /rates/1'   => 'rates#destroy', id: '1'
  end
end
