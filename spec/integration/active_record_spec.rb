require 'spec_helper'

describe "User" do
  before :each do
    @user = User.create!(name: "John Doe")
  end
  
  it "just registered gains 5 points" do
    @user.points.should eq 5
  end

  it "creating a post gains 7 points" do
    @post = @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
    @user.points.should eq 12
  end

  it "deletes own post gains 1 point" do
    @post = @user.posts.create!(title: 'The quick brown fox jumps over the lazy dog')
    @post.destroy
    @user.points.should eq 11
  end

  it "buys a product loses points equal to product points equivilant" do
    @product = Product.create!(points: 3)
    @product.buy
    @user.points.should eq 2
  end
end

