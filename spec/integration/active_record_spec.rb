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

  it "gains points before hitting maximum" do
    @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog #2')
    @user.points.should eq 19
  end

  it "stops gaining after hitting maximum" do
    @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
    @user.points.should eq 19
  end

  it "loses points for deletion" do
    @post.destroy
    @user.points.should eq 11
  end
end

describe "User" do
  # it "buys a product loses points equal to product points equivilant" do
  # @user = User.create!(name: "John Doe")
  #   @product = Product.create!(points: 3)
  #   @product.buy
  #   @user.points.should eq 2
  # end
end

