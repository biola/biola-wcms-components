module BiolaWcmsComponents
  class Configuration
    attr_accessor :default_redactor_buttons

    def initialize
      @default_redactor_buttons = ['bold', 'italic', 'orderedlist', 'unorderedlist']
    end
  end
end
