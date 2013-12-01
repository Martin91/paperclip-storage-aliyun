require 'spec_helper'
require "open-uri"
require 'net/http'
require 'support/post'

describe Paperclip::Storage::Aliyun do
  before :each do
    @file = load_attachment('girl.jpg')
    @post = Post.create attachment: @file
  end

  after :each do
    if @post && @post.respond_to?(:id)
      @post.destroy!
    end

    @file.close
  end

  describe "#flush_writes" do
    it "uploads the attachment to Aliyun" do
      open(@post.attachment.url).should_not be_nil
    end

    it "get uploaded file from Aliyun" do
      attachment = open @post.attachment.url
      @file.size.should == attachment.size
    end
  end

  describe "#exists?" do
    it "returns true if the file exists on Aliyun" do
      @post.attachment.exists?.should be_true
    end

    it "returns false if the file doesn't exist on Aliyun" do
      post = Post.new attachment: @file
      post.attachment.exists?.should be_false
    end
  end

  describe "#flush_deletes" do
    it "deletes the attachment from Aliyun" do
      attachment_url = @post.attachment.url
      @post.destroy

      Net::HTTP.get_response(URI.parse(attachment_url)).code.should == "404"
    end
  end

  describe "#copy_to_local_file" do
    it "copies file from Aliyun to a local file" do
      destination = File.join(Bundler.root, "tmp/photo.jpg")
      @post.attachment.copy_to_local_file(:original, destination)
      File.exists?(destination).should be_true
      File.delete destination
    end
  end
end
