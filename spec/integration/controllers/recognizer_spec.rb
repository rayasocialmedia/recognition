require 'spec_helper'

describe "Pages" do
  before :each do
    @user = User.create!(name: "Jane Smith")
  end
    
  it "may reward users with points for visiting" do
    visit posts_path # Should now get the extra 6 points
    visit user_path(@user)
    page.should have_content("Points: 11")
  end

  it "may reward users with points for visiting pages if condition was met" do
    post = @user.posts.create(title: 'hello world!')
    visit post_path(post, foo: 'bar')
    visit user_path(@user)
    page.should have_content("Points: 12")
  end
end