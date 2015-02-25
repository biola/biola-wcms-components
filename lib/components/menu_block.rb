class MenuBlock
  attr_reader :items
  attr_reader :context
  attr_reader :html_options

  def initialize(view_context, html_options = {})
    @context = view_context
    @html_options = html_options
    @items = []
  end

  # Adds a menu item to the menu block
  #
  # ==== Options
  # * <tt>default: false</tt> - Whether or not this item is default if nothing else is active.
  # * <tt>match_params: {}</tt> - Pass a hash to compare with params. Leave blank for defaults matchers.
  #   To use: <tt>{action: [:new, :create], id: '12345'}</tt>.
  #
  # ==== Examples
  # For a regular default menu item
  #
  #   = menu.add_item('Profile', default: true) { edit_person_path(@person, page: 'profile') }
  #
  # For a subitem you can so something like this
  #   .subitems
  #     = menu.add_item('New Custom Profile', match_params: {action: [:new, :create]}) { new_person_custom_profile_path(@person) }
  #
  def add_item(name, default: false, match_params: {}, &route_block)
    items << MenuItem.new(context, name, default: default, match_params: match_params, &route_block)

    placeholder(items.length - 1)
  end

  def render(&block)
    # Grab the HTML from the block so that custom HTML can be injected into the menu
    html = context.capture(self, &block)

    items.each_with_index do |item, i|
      opts = html_options.dup || {}
      if item.active? || (items.none?(&:active?) && item.default?)
        opts[:class] = [html_options[:class], 'active'].compact.join(' ')
      end

      html[placeholder(i)] = context.link_to(item.name, item.route, opts)
    end

    html
  end

  private

  def placeholder(number)
    # Placeholder for delayed rendering. We need this so that we can work
    # with all of the menu items so that by the time we render the first one,
    # which could be the default, we know whether or not any others are active.
    "[[menu_block:#{number}]]"
  end

  class MenuItem
    attr_reader :name
    attr_reader :route_block
    attr_reader :default
    attr_reader :match_params

    alias :default? :default

    def initialize(context, name, default: false, match_params: {}, &route_block)
      @context = context
      @name = name
      @route_block = route_block
      @default = default
      @match_params = match_params
    end

    def route
      @route ||= route_block.call
    end

    def active?
      matches = []

      # Set default match_params. For example: This is the default matcher for :controller if :controller isn't specified
      match_params[:controller] ||= recognized_route[:controller]

      # Make sure everything in match_params is contained in params.
      match_params.each do |key,val|
        # This will handle arrays, strings, numbers, etc. params should always return a string or nil.
        matches << Array(val).compact.map(&:to_s).include?(params[key])
      end

      # Loop through query parameters to make sure they match
      ::Rack::Utils.parse_query(URI.parse(route).query).each do |param, val|
        matches << (params[param] == val)
      end

      matches.all?
    end

    private

    def request
      @context.request
    end

    def params
      @context.params
    end

    def recognized_route
      @recognized_route ||= (
        recognizable_path = without_script_name { route_block.call }
        Rails.application.routes.recognize_path(recognizable_path)
      )
    end

    # The router won't recognize routes with a script_name
    # So we need to temporarily set the script_name to nil
    # so we can generate a path the router will like.
    def without_script_name(&block)
      script_name = request.script_name
      request.script_name = nil

      val = block.call

      request.script_name = script_name

      val
    end
  end
end
