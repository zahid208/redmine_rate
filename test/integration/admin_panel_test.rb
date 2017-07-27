require_relative '../test_helper'

class AdminPanelTest < RedmineRateIntegrationTest
  def setup
    @last_caching_run = 4.days.ago
    @last_cache_clearing_run = 7.days.ago

    Setting.plugin_redmine_rate[:last_caching_run] = @last_caching_run.to_s
    Setting.plugin_redmine_rate[:last_cache_clearing_run] = @last_cache_clearing_run.to_s

    login_as 'admin', 'admin'
  end

  def teardown
    logout
  end

  context 'Rate Caches admin panel' do
    should 'show the last run timestamp for the last caching run' do
      visit('/settings/plugin/redmine_rate?tab=caches')

      assert_selector '#caching-run' do
        assert_selector 'p', text: /#{format_time(@last_caching_run)}/
      end
    end

    should 'show the last run timestamp for the last cache clearing run' do
      visit('/settings/plugin/redmine_rate?tab=caches')

      assert_selector '#cache-clearing-run' do
        assert_selector 'p', text: /#{format_time(@last_cache_clearing_run)}/
      end
    end

    should 'have a button to force a caching run' do
      visit('/rate_caches?cache=missing')
      assert_equal 200, status_code

      appx_clear_time = Time.zone.today.strftime('%m/%d/%Y')
      assert_selector '#caching-run' do
        assert_selector 'p', text: /#{appx_clear_time}/
      end
    end

    should 'have a button to force a cache clearing run' do
      visit('/rate_caches?cache=reload')
      assert_equal 200, status_code

      appx_clear_time = Time.zone.today.strftime('%m/%d/%Y')
      assert_selector '#cache-clearing-run' do
        assert_selector 'p', text: /#{appx_clear_time}/
      end
    end
  end
end
