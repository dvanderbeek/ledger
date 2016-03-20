require 'rails_helper'

RSpec.describe ApplicationHelper do
  it "returns the correct class for a notice" do
    expect(helper.flash_class(:notice)).to eq "info"
  end

  it "returns the correct class for a error" do
    expect(helper.flash_class(:error)).to eq "danger"
  end

  it "returns the correct class for a alert" do
    expect(helper.flash_class(:alert)).to eq "warning"
  end
end
