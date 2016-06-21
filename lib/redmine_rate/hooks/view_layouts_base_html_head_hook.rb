module RedmineRate
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(_context = {})
        stylesheet_link_tag(:rate, plugin: 'redmine_rate')
      end
    end
  end
end
