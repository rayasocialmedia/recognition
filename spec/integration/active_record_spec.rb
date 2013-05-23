require 'spec_helper'

describe "Registration" do
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

describe "Voucher" do
  before :each do
    @user ||= User.create!(name: "John Doe")
    @voucher = Voucher.create!(amount: 40)
  end

  it "code length is 14" do
    @voucher.code.length.should eq 14
  end

  it "redemption adds points to user" do
    @voucher.redeem @user
    @user.points.should eq 45
  end

  it "can be redeemed only once per user" do
    @voucher.redeem @user
    @voucher.redeem @user
    @voucher.redeem @user
    @user.points.should eq 45
  end

  it "can be redeemed only once if it is disposable" do
    @another_user ||= User.create!(name: "Jane Smith")
    @voucher.redeem @user
    @voucher.redeem @another_user
    @another_user.points.should eq 5
  end

  it "marked as reusable can be redeemed by multiple users" do
    @another_user ||= User.create!(name: "Jane Smith")
    @reusable_voucher = Voucher.create!(amount: 20, reusable: true)
    @reusable_voucher.redeem @user
    @reusable_voucher.redeem @another_user
    @another_user.points.should eq 25
  end

  it "can not be redeemed if it expired" do
    @another_voucher = Voucher.create!(amount: 10, expires_at: DateTime.now)
    @another_voucher.redeem @user
    @user.points.should eq 5
  end

  it "can be redeemed if it expires in the future" do
    @another_voucher = Voucher.create!(amount: 13, expires_at: (DateTime.now + 1.day))
    @another_voucher.redeem @user
    @user.points.should eq 18
  end

  it "can not be redeemed if custom validators returned false" do
    @another_voucher = Voucher.create!(amount: 1000)
    @another_voucher.redeem @user
    @user.points.should eq 5
  end

end

