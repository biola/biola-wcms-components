class PresentationDataEditor
  attr_reader :view
  attr_reader :data
  attr_reader :schema
  attr_reader :form

  # Expects a hash schema definition.
  #   will probably come from presentation_data_template.schema
  def initialize(view_context, data, schema, form)
    @view = view_context
    @data = data
    @schema = schema
    @form = form
  end

  def render
    presentation_data_editor if schema.is_a? Array
  end


  private

  def presentation_data_editor
    view.content_tag :div, id: 'presentation_data_editor' do
      choose_editor_link + view.content_tag(:div, "", class: 'clearfix') +
      render_editor
    end
  end

  def choose_editor_link
    if view.current_user.try(:admin?)
      if view.params[:edit_raw_data] == 'true'
        view.link_to('Simple Editor', view.params.merge(edit_raw_data: nil), class: 'pull-right')
      else
        view.link_to('Edit Raw Data', view.params.merge(edit_raw_data: true), class: 'pull-right')
      end
    else
      ''.html_safe
    end
  end

  def render_editor
    if view.params[:edit_raw_data] == 'true' && view.current_user.try(:admin?)
      raw_data_editor
    else
      array_of_attributes(schema)
    end
  end

  def raw_data_editor
    form.text_area(:presentation_data_json, class: 'form-control json_editor') +
    view.content_tag(:div, '', id: 'json_schema_editor')
  end

  def array_of_attributes(attributes, parent_keys=[], wrapper_class: 'nest')
    view.content_tag(:div, class: wrapper_class) do
      Array(attributes).map do |attribute|
        build_form_attribute(ActiveSupport::HashWithIndifferentAccess.new(attribute), parent_keys)
      end.join(" ").html_safe
    end
  end

  def build_form_attribute(attribute, parent_keys)
    case attribute[:type]
    when 'hash'
      build_hash(attribute, parent_keys)
    when 'array'
      build_array(attribute, parent_keys)
    when 'string', nil  # String should be the default value
      build_string(attribute, parent_keys)
    when 'image'
      build_image_uploader(attribute, parent_keys)
    when 'html'
      build_html(attribute, parent_keys)
    end
  end



  ############################
  ### Type specific Builders
  ############################
  def build_hash(attribute, parent_keys)
    view.content_tag(:h4, attribute[:name].titleize) +
    array_of_attributes(attribute[:nested_attributes], parent_keys + Array(attribute[:name]))
  end

  def build_array(attribute, parent_keys)
    view.content_tag(:div, class: 'array_wrapper') do
      view.content_tag(:h4, attribute[:name].titleize) +
      # build empty form template for creating new items
      build_array_with_data(
        attribute[:nested_attributes],
        parent_keys,
        attribute[:name]
      )
    end
  end

  def build_array_with_data(attributes, parent_keys, array_name)
    view.content_tag(:div, class: 'nest existing_array') do
      build_array_framework(attributes, parent_keys, array_name) +
      build_array_items(attributes, parent_keys, array_name) +
      view.content_tag(:a, 'Add Item', href:'#', class: 'add_array_item', tabindex: '-1')
    end
  end

  def build_array_items(attributes, parent_keys, array_name)
    Array(data_grab(parent_keys, array_name)).each_with_index.map do |v,i|
      view.content_tag :div, class: 'array_item' do
        view.content_tag(:a, 'Delete Item', href:'#', class: 'delete_array_item pull-right', tabindex: '-1') +
        array_of_attributes(attributes, parent_keys + Array(array_name) + Array(i), wrapper_class: nil)
      end
    end.join(" ").html_safe
  end

  def build_array_framework(attributes, parent_keys, array_name)
    view.content_tag(:div, class: 'array_item framework') do
      view.content_tag(:a, 'Delete Item', href:'#', class: 'delete_array_item pull-right', tabindex: '-1') +
      array_of_attributes(attributes, parent_keys + Array(array_name) + Array(0), wrapper_class: nil)
    end
  end


  def build_string(attribute, parent_keys)
    view.content_tag :div, class: 'form-group' do
      view.label_tag(attribute[:name]) +
      view.text_field_tag(
        form_name(parent_keys, attribute[:name]),
        data_grab(parent_keys, attribute[:name]),
        {
          class: "form-control #{attribute[:class]}",
          id: attribute_id(parent_keys, attribute[:name]),
          placeholder: attribute[:placeholder]
        }
      )
    end
  end

  def build_image_uploader(attribute, parent_keys)
    view.content_tag :div, class: 'form-group' do
      view.label_tag(attribute[:name]) +
      view.text_field_tag(
        form_name(parent_keys, attribute[:name]),
        data_grab(parent_keys, attribute[:name]),
        {
          class: "form-control drop-image-uploader #{attribute[:class]}",
          id: attribute_id(parent_keys, attribute[:name]),
          placeholder: "Drop image here"
        }
      )
    end
  end

  def build_html(attribute, parent_keys)
    view.content_tag :div, class: 'form-group' do
      view.label_tag(attribute[:name]) +
      view.text_area_tag(
        form_name(parent_keys, attribute[:name]),
        data_grab(parent_keys, attribute[:name]),
        {
          class: "redactor #{attribute[:class]}",
          id: attribute_id(parent_keys, attribute[:name]),
          'data-buttons' => editor_buttons(attribute)
        }
      )
    end
  end



  ############################
  ### helper methods
  ############################

  # This will create the name parameter for a given form input
  # Example:
  #   research(hash) > books(array) > 2(array index) > title(attribute_name)
  #     will become
  #   "pdata[research][books][][title]"
  def form_name(parent_keys, attr_name)
    p = ['pdata'] + parent_keys + [attr_name]
    p.compact.each_with_index.map do |v,i|
      if i == 0
        v   # don't wrap the first key in brackets
      elsif v.is_a?(Integer)
        "[]" # Skip the number, this will be an array...
      else
        "[#{v}]"
      end
    end.join('')
  end

  # Creates an underscored version of the form_name above.
  # Example:
  #   "pdata_research_books_2_title"
  def attribute_id(parent_keys, attr_name)
    p = ['pdata'] + parent_keys + [attr_name]
    p.compact.join('_')
  end

  # Will look up the data given the correct path
  def data_grab(parent_keys, attr_name)
    path = parent_keys + [attr_name]

    # I'm using inject here to traverse the data hash with each sequential
    #   key or index value. I use `try` just in case the data is not there
    #   and `last` is nil.
    path.compact.inject(data) do |last, p|
      if last.is_a? Array
        # Use a number to reference the array element
        last.try(:[], p.to_i)
      elsif last.is_a? Hash
        last.try(:[], p.to_s)
      end
    end
  end

  def editor_buttons(attribute)
    default_buttons = %w(bold italic unorderedlist orderedlist link)
    buttons = attribute[:editor_buttons].to_s.split(' ').presence || default_buttons
    buttons.push('html') if !buttons.include?('html') && view.current_user.try(:admin?)
    buttons.push('fullscreen') unless buttons.include?('fullscreen')
    buttons.join(' ')
  end

end
