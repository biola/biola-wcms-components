# Biola WCMS Components

This provides reusable components for our differnet WCMS apps

## Installation

Add this line to your application's Gemfile:

    gem 'biola_wcms_components'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install biola_wcms_components

#### Dependencies

* coffee-rails
* slim

## Usage

### Rails > 3.1

Include the following in `application.css.scss`.

    @import "biola-frontend-toolkit";

Include the following in `application.js.coffee`.

    #= require biola-frontend-toolkit


#### Other requirements

* `current_user` - When a user is logged in
* `logout_path` - Should return a link to the logout path
* `/whateverpath?login=true` - Should be caught by ApplicationController and redirect to login page if not already logged in.


#### Configuration

Create a new file called `/config/initializers/biola_wcms_components.rb`

    BiolaWcmsComponents.configure do |config|
      config.app_name = Settings.app.name
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
