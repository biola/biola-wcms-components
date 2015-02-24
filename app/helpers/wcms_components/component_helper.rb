module WcmsComponents
  module ComponentHelper

    def wcms_component(slug, properties={})
      render "wcms_components/#{slug}", properties
    end

  end
end
