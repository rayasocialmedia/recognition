require 'spec_helper'

  describe "user" do
    before do
      # @forum = Forem::Forum.create!(:title => "Welcome to Forem!",
      #                              :description => "A placeholder forum.")
    end

    it "user profile" do
      visit user_path
      page.should have_content("Points: 0")
    end

  end