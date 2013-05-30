require 'spec_helper'

describe "Gift" do
  before :each do
    @user ||= User.create!(name: "John Doe")
    @gift = Gift.create!(amount: 2)
  end

  it "code length is 20" do
    @gift.code.length.should eq 20
  end

  it "redemption removes points from user" do
    @gift.redeem @user
    @user.points.should eq 3
  end

  it "can be redeemed if the user has enough points" do
    @another_gift = Gift.create!(amount: 5)
    @another_gift.redeem @user
    @user.points.should eq 0
  end

  it "marked as reusable can be redeemed by multiple users" do
    @another_user ||= User.create!(name: "Jane Smith")
    @reusable_gift = Gift.create!(amount: 4, reusable: true)
    @reusable_gift.redeem @user
    @reusable_gift.redeem @another_user
    @another_user.points.should eq 1
  end

  context 'validates' do
    it "can not be redeemed if the user has not enough points" do
      @another_gift = Gift.create!(amount: 50)
      @another_gift.redeem @user
      @user.points.should eq 5
    end

    it "can be redeemed only once per user" do
      @gift.redeem @user
      @gift.redeem @user
      @gift.redeem @user
      @user.points.should eq 3
    end

    it "can be redeemed only once if it is disposable" do
      @another_user ||= User.create!(name: "Jane Smith")
      @gift.redeem @user
      @gift.redeem @another_user
      @another_user.points.should eq 5
    end

    it "can not be redeemed if it expired" do
      @another_gift = Gift.create!(amount: 5, expires_at: DateTime.now)
      @another_gift.redeem @user
      @user.points.should eq 5
    end

    it "can be redeemed if it expires in the future" do
      @another_gift = Gift.create!(amount: 3, expires_at: (DateTime.now + 1.day))
      @another_gift.redeem @user
      @user.points.should eq 2
    end

    it "can not be redeemed if custom validators returned false" do
      @expired_gift = Gift.create!(amount: 20000)
      @expired_gift.redeem @user
      @user.points.should eq 5
    end
  end
  
  context 'error' do
    it "can not be redeemed if the user has not enough points" do
      @another_gift = Gift.create!(amount: 50)
      @another_gift.redeem @user
      @another_gift.errors.messages.count.should eq 1
    end

    it "message specified if it is not redeemable" do
      @another_user ||= User.create!(name: "Jane Smith")
      @gift.redeem @user
      @gift.redeem @another_user
      @gift.errors.messages.count.should eq 1
    end

    it "message specified if it expired" do
      @another_gift = Gift.create!(amount: 5, expires_at: DateTime.now)
      @another_gift.redeem @user
      @another_gift.errors.messages.count.should eq 1
    end
  end

end