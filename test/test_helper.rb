# Load the normal Rails helper
require_relative "../../../test/test_helper"
require_relative "../../../test/object_helpers"
require_relative "object_helpers"
require "webrat"

ActiveSupport::TestCase.fixture_path = File.dirname(__FILE__) + '/../../../test/fixtures'

class ActiveSupport::TestCase
  fixtures :users, :issues, :projects, :time_entries
end

Webrat.configure do |config|
  config.mode = :rails
end

module IntegrationTestHelper
  def login_as(user="existing", password="existing")
    visit "/login"
    fill_in 'Login', :with => user
    fill_in 'Password', :with => password
    click_button 'login'
    assert_response :success
    assert User.current.logged?
  end

  def logout
    visit '/logout'
    assert_response :success
    assert !User.current.logged?
  end

  def assert_forbidden
    assert_response :forbidden
    assert_template 'common/error'
  end

  def assert_requires_login
    assert_response :success
    assert_template 'account/login'
  end

end

class ActionController::IntegrationTest
  include IntegrationTestHelper
end
