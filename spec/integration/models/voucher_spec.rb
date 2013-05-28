require 'spec_helper'

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