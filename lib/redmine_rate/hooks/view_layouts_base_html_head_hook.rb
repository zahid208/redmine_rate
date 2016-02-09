module RedmineRate
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        css = <<-CSS
          #admin-menu a.rate-caches {
            background-image: url('/plugin_assets/redmine_rate/images/database_refresh.png');
          }
        CSS
        content_tag(:style, css.html_safe, type: "text/css")
      end
    end
  end
end
