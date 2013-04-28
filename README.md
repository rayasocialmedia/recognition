# Recognition

A fully-fledged reward system for Rails 3.1+.

## Installation

Add this line to your application's Gemfile:

    gem 'recognition'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install recognition

## Usage

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

## Contributing

Please see CONTRIBUTING.md for details.

##Credits
recognition was originally written by Omar Abdel-Wahab.

![RSM](http://rayasocialmedia.com/images/logo.png)

recognition is maintained and funded by Raya Social Media.

## License
recognition is Copyright © 2013 Raya Social Media. It is free software, and may be redistributed under the terms specified in the LICENSE file.
