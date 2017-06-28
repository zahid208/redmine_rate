require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start :rails do
  add_filter 'init.rb'
  root File.expand_path(File.dirname(__FILE__) + '/..')
end

require_relative '../../../test/test_helper'
require_relative '../../../test/object_helpers'
require_relative 'object_helpers'
require 'capybara/rails'

ActiveSupport::TestCase.fixture_path = File.dirname(__FILE__) + '/../../../test/fixtures'

class ActiveSupport::TestCase
  fixtures :users, :issues, :projects, :time_entries
end

class RedmineRateIntegrationTest < Redmine::IntegrationTest
  include Redmine::I18n
  include Capybara::DSL

  def login_as(user = 'existing', password = 'existing')
    visit '/login'

    within('#login-form > form') do
      fill_in 'Login', with: user
      fill_in 'Password', with: password
      find('input[type=submit]').click
    end

    assert_equal 200, page.status_code
    assert_equal '/my/page', page.current_path
  end

  def logout
    click_link l(:label_logout)
    assert_equal 200, page.status_code
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
