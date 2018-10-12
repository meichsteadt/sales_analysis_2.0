require 'rails_helper'

describe User do
  it "should have the correct sales data" do
    user = User.first
    sales_year = user.sales_year

    expect user.email.to eq("hal.eichsteadt@gmail.com")
  end
end
