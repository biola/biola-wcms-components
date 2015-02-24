module WcmsComponents
  module AlertsHelper
    def all_alerts
      flash_alerts + model_alerts
    end

    def flash_alerts
      flash.map { |key,val| {type: key, message: val} }
    end

    def model_alerts(model = nil)
      model ||= instance_variable_get("@#{controller_name.singularize}")

      return [] if model.nil?

      model.errors.full_messages.map { |msg| {type: :error, message: msg} }
    end

    def alert_icon(type)
      case type.to_s.to_sym
      when :error, :alert
        'fa fa-exclamation-circle'
      when :warn, :warning
        'fa fa-warning'
      else
        'fa fa-info-circle'
      end
    end

    def alert_class(type)
      case type.to_s.to_sym
      when :error, :alert
        'alert-danger'
      when :warn, :warning
        'alert-warning' # default yellow
      else
        'alert-info'
      end
    end
  end
end
