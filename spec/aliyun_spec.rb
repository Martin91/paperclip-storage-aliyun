require 'spec_helper'

require "net/http"

describe Aliyun::Connection do
  before :all do
    @connection = ::Aliyun::Connection.new
    @path = 'a/a.jpg'
  end

  describe '#put' do
    it "upload the attachment" do
      url = @connection.put @path, load_attachment("girl.jpg")
      Net::HTTP.get_response(URI.parse(url)).code.should == "200"
    end
  end

  describe '#delete' do
    it "delete the attachment" do
      url = @connection.delete @path
      Net::HTTP.get_response(URI.parse(url)).code.should == "404"
    end
  end

  describe "#exists?" do
    before :all do
      @connection.put @path, load_attachment("girl.jpg")
    end

    it "should return true if the file has been uploaded" do
      @connection.exists?(@path).should be_true
    end

    it "should return false if the specified file didn't exist" do
      @connection.delete @path
      @connection.exists?(@path).should be_false
    end
  end
end
