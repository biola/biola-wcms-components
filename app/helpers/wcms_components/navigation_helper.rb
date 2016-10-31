module WcmsComponents
  module NavigationHelper

    # Set class on active navigation items
    def nav_link(text, path_helper)
      # The router can't match against a relative root in the path
      # so we need to strip it out with script_name: ''.
      # Note: passing nil as the script_name does not work
      router_path = send(path_helper, script_name: '')
      real_path = send(path_helper)

      recognized = ::Rails.application.routes.recognize_path(router_path)

      if policy(recognized[:controller].classify.constantize).index?  # make sure user has permission to index this controller
        if recognized[:controller] == params[:controller] # && recognized[:action] == params[:action]
          content_tag(:li, :class => "descendant active") do
            link_to( text, real_path)
          end
        else
          content_tag(:li, :class => "descendant") do
            link_to( text, real_path)
          end
        end
      end
    end

    # Gets used by the side menu / page navigation
    def menu_block(html_options = {}, &block)
      MenuBlock.new(self, html_options).render(&block)
    end

  end
end
