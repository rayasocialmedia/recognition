require 'spec_helper'

  describe "users" do
    before :each do
      @user = User.create!(name: "Jane Smith")
    end
    
    it "get 6 points for visiting posts page" do
      visit posts_path # Should now get the extra 6 points
      visit user_path(@user)
      page.should have_content("Points: 11")
      # visit posts_path # Should now get the extra 6 points
      # visit user_path(@user)
      # page.should have_content("Points: 17")
      # visit posts_path # Should now get the extra 6 points
      # visit user_path(@user)
      # page.should have_content("Points: 23")
    end
  end