# Recognition

A fully-fledged reward system for Rails 3.1+.

## Features

*  Reward users with points for any model method or ActiveRecord CRUD operation.
*  Create vouchers that users can redeem for points.

## Links

*  [Installation](#Installation)
*  [Usage](#Usage)
*  [Examples](#Examples)
*  [Wiki](https://github.com/rayasocialmedia/recognition/wiki)
*  [Code Documentation](http://rubydoc.info/gems/recognition/frames)
*  [Changelog](https://raw.github.com/rayasocialmedia/recognition/master/CHANGELOG.txt)
*  [License](https://raw.github.com/rayasocialmedia/recognition/master/LICENSE.txt)

## Installation

Add this line to your application's Gemfile:

    gem 'recognition'

And then execute:

    $ bundle

Then, you need to run the generator:

    $ rails generate recogintion:install

And finally, configure your REDIS server connection parameters in: `config/recognition.yml`

## Usage

### Points

Assuming you have two models User and Post and you want to give users points for the following:

5 points for registration
7 points for adding new posts, can be earned multiple times with no limit
2 point for deleting posts, can be earned twice
2 points for visiting their profile, earned once

app/models/user.rb:

    class User < ActiveRecord::Base
      attr_accessible :name
      has_many :posts
      acts_as_recognizable initial: 5
    end

app/models/post.rb:

    class Post < ActiveRecord::Base
      attr_accessible :title, :user_id
      belongs_to :user
      recognize :user, for: :create, gain: 7
      recognize :user, for: :destroy, loss: 2, maximum: 4
    end

**Important:**
Due to the way Ruby method aliasing work, if you need to recognize users for 
non-ActiveRecord actions (anything that's not :create, :update and :destroy),
make sure you add the `recognize` line *after* the method you want to 
recognize the user for.

app/controllers/profiles_controller.rb:

    class ProfilesController < ApplicationController
      recognize :current_user, for: :index, amount: 6, maximum: 12
      def index
        @user = User.find(params[:id])
        respond_to do |format|
          format.html
        end
      end
    end

### Vouchers

Use an existing model or generate a new one using:

    $ rails generate recogintion:voucher

Your model might have the following attributes:

*  `:code` **required**
*  `:amount` **required**
*  `:expires_at` _optional_
*  `:reusable` _optional_

You can specify the following extra parameters for vouchers:

* `:prefix` can be a number, string or method name or even an anonymous function.
* `:suffix` can be a number, string or method name or even an anonymous function.

app/models/voucher.rb:

    class Voucher < ActiveRecord::Base
      attr_accessible :code, :amount, :expires_at, :reusable
        acts_as_voucher code_length: 14
    end

Then, you may do:

    voucher = Voucher.create!(amount: 20, expires_at: (DateTime.now + 1.day), reusable: true)
    voucher.redeem current_user

## Example
The following won't work:

    class Post < ActiveRecord::Base
      attr_accessible :title, :user_id
      recognize :user, for: :foo, gain: 2
      def foo
        # do something useful
      end
    end

This one will:

    class Post < ActiveRecord::Base
      attr_accessible :title, :user_id
      def foo
        # do something useful
      end
      recognize :user, for: :foo, gain: 2
    end


## Contributing

Please see CONTRIBUTING.md for details.

## Credits
recognition was originally written by Omar Abdel-Wahab.

![RSM](http://rayasocialmedia.com/images/logo.png)

recognition is maintained and funded by Raya Social Media.

## License
recognition is Copyright © 2013 Raya Social Media. It is free software, and may be redistributed under the terms specified in the LICENSE file.
