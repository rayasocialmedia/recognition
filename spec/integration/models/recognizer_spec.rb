require 'spec_helper'

describe "Recognizer" do
  before :each do
    @user ||= User.create!(name: "John Doe")
    @post = @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
  end
  
  it "supports ActiveRecord after_create callback" do
    @user.points.should eq 12
  end

  it "supports ActiveRecord after_update callback" do
    @post.title = '[Updated] The quick brown fox jumps over the lazy dog'
    @post.save
    @user.points.should eq 13
  end

  it "supports ActiveRecord after_destroy callback" do
    @post.destroy
    @user.points.should eq 11
  end

  it "adds points to user before hitting maximum" do
    @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog #2')
    @user.points.should eq 19
  end

  it "stops gaining after hitting maximum" do
    @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
    @user.points.should eq 19
  end

  it "stops gaining from other actions sharing the same group after hitting maximum" do
    post = @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
    post.title = '[Updated] The quick brown fox jumps over the lazy dog'
    post.save
    @user.points.should eq 19
  end
end

describe "Recognizer" do
  before :each do
    @user ||= User.create!(name: "John Doe")
    @another_user ||= User.create!(name: "Jane Smith")
    @product = Product.create!(owner: @user, points: 2)
  end

  it "supports ActiveRecord after_create callback specifying gain using a symbol" do
    @user.points.should eq 7
  end

  it "adds points for firing custom model methods specifying loss using a lambda" do
    @product.buy @another_user
    @another_user.points.should eq 1
  end
  
  it "does not add points for firing custom model methods if the method returned false" do
    @product.false_buying @another_user
    @another_user.points.should eq 5
  end
end