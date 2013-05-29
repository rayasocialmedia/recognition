require 'spec_helper'

describe "Recognizable" do
  before :all do
    @user ||= User.create!(name: "John Doe")
  end
  
  it "user responds to .points method" do
    @user.points.should be_a_kind_of Numeric
  end
  
  it "user gains initial points after creation" do
    @user.points.should eq 5
  end
end

