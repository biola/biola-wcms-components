module WcmsComponents
  module NavigationHelper

    # Set class on active navigation items
    def nav_link(text, path_helper)
      # The router can't match against a relative root in the path
      # so we need to strip it out with script_name: nil.
      router_path = send(path_helper, script_name: nil)
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

  end
end
