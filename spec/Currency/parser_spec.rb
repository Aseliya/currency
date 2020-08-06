require 'spec_helper'
require './lib/currency/parser'

RSpec.describe Currency::Request do
  it "is not created without access key" do
    expect{Currency::Request.new}.to raise_error ArgumentError
  end


  it "is create with access token" do
    access = Currency::Request.new(access_key: '662369652784e5f729de1b470b6a6c2a')
    expect(access).to be_instance_of(described_class)
  end
end