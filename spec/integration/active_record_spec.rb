require 'spec_helper'

describe "Registration:" do
  it "user gains initial points after registration" do
    user = User.create!(name: "John Doe")
    user.points.should eq 5
  end
end

describe "User" do
  before :each do
    @user ||= User.create!(name: "John Doe")
    @post = @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
  end
  
  it "gains points for creating" do
    @user.points.should eq 12
  end

  it "gains points for updating" do
    @post.title = '[Updated] The quick brown fox jumps over the lazy dog'
    @post.save
    @user.points.should eq 13
  end

  it "gains points before hitting maximum" do
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

  it "loses points for deletion" do
    @post.destroy
    @user.points.should eq 11
  end
end

describe "Product" do
  before :each do
    @user ||= User.create!(name: "John Doe")
    @another_user ||= User.create!(name: "Jane Smith")
    @product = Product.create!(owner: @user, points: 2)
  end

  it "owner gains points equal to product points for creation" do
    @user.points.should eq 7
  end

  it "buyer loses points equal to double product points" do
    @product.buy @another_user
    @another_user.points.should eq 1
  end
  
  it "buyer loses no points if product buying is cancelled" do
    @product.false_buying @another_user
    @another_user.points.should eq 5
  end
end

