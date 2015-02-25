# Biola WCMS Components

This provides reusable UX components for our differnet WCMS projects

## Installation

Add this line to your application's Gemfile:

    gem 'biola_wcms_components'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install biola_wcms_components

#### Dependencies

* ace-rails-ap
* coffee-rails
* sass-rails
* slim
* rails (this is not an explicit dependency but I haven't tested it using anything else)

## Usage

### Rails > 3.1

Include the following in `application.css.scss`.

    @import "biola-wcms-components";

Include the following in `application.js.coffee`.

    #= require biola-wcms-components


### Components

In your view file, you will render `wcms_component("path/to/component", options)`

Example:

    = wcms_component "forms/presentation_data_editor",
      schema: @generic_object.presentation_data_template.schema,
      data: @generic_object.presentation_data,
      form: f,
      embedded_image_url: create_embedded_images_url

Currently, look in `app/views/wcms_components` for available components.


#### Other requirements

* `current_user` - should be defined an ApplicationController. Should return user when logged in

#### Configuration

Create a new file called `/config/initializers/biola_wcms_components.rb`

    BiolaWcmsComponents.configure do |config|
      config.default_redactor_buttons = ['bold', 'italic', 'orderedlist', 'unorderedlist']
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
