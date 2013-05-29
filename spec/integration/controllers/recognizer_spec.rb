require 'spec_helper'

describe "ActionController" do
  before :each do
    @user = User.create!(name: "Jane Smith")
  end
    
  it "adds points to users for requesting specific action" do
    visit posts_path
    visit user_path(@user)
    page.should have_content("Points: 11")
  end

  it "adds points to users for requesting specific action and specify user using a lambda function" do
    visit new_post_path(uid: @user.id)
    visit user_path(@user)
    page.should have_content("Points: 7")
  end

  it "subtract points from user for requesting specific action and specify amount using a lambda function" do
    another_user = User.create!(name: 'Jane Smith')
    post = @user.posts.create(title: 'hello world!')
    visit post_path(post, foo: 'bar')
    visit user_path(another_user)
    page.should have_content("Points: 4")
  end
end