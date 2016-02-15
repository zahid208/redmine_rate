require_relative "../test_helper"

class AdminPanelTest < RedmineRateIntegrationTest
  def setup
    @last_caching_run = 4.days.ago.to_s
    @last_cache_clearing_run = 7.days.ago.to_s

    Setting.plugin_redmine_rate = {
      'last_caching_run' => @last_caching_run,
      'last_cache_clearing_run' => @last_cache_clearing_run
    }

    login_as "admin", "admin"
  end

  def teardown
    logout
  end

  context "Rate Caches admin panel" do
    should "be listed in the main Admin section" do
      click_link "Administration"
      assert_equal 200, status_code

      assert_selector "#admin-menu" do
        assert_selector "a.rate-caches"
      end

    end

    should "show the last run timestamp for the last caching run" do
      click_link "Administration"
      click_link "Rate Caches"

      assert_selector '#caching-run' do
        assert_selector 'p', text: /#{format_time(@last_caching_run)}/
      end

    end

    should "show the last run timestamp for the last cache clearing run" do
      click_link "Administration"
      click_link "Rate Caches"

      assert_selector '#cache-clearing-run' do
        assert_selector 'p', text: /#{format_time(@last_cache_clearing_run)}/
      end

    end

    should "have a button to force a caching run" do
      click_link "Administration"
      click_link "Rate Caches"
      click_button "Load Missing Caches"

      assert_equal 200, status_code

      appx_clear_time = Date.today.strftime("%m/%d/%Y")

      assert_selector '#caching-run' do
        assert_selector 'p', text: /#{appx_clear_time}/
      end

    end

    should "have a button to force a cache clearing run" do
      click_link "Administration"
      click_link "Rate Caches"
      click_button "Clear and Load All Caches"

      assert_equal 200, status_code

      appx_clear_time = Date.today.strftime("%m/%d/%Y")

      assert_selector '#cache-clearing-run' do
        assert_selector 'p', text: /#{appx_clear_time}/
      end

    end
  end
end
