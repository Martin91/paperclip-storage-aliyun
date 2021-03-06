require 'spec_helper'
require 'open-uri'
require 'net/http'
require 'support/post'

describe Paperclip::Storage::Aliyun do
  before :all do
    @file = load_attachment('girl.jpg')
    @post = Post.create attachment: @file
  end

  after :all do
    @post.destroy! if @post && @post.respond_to?(:id)
    @file.close
  end

  describe 'style urls' do
    before { @url = 'http://martin-test.oss-cn-hangzhou.aliyuncs.com/public/system/posts/attachments/000/000/001/original/girl.jpg' }
    it { expect(@post.attachment.aliyun_upload_url).to eq(@url) }
    it { expect(@post.attachment.aliyun_external_url).to eq(@url) }
    it { expect(@post.attachment.aliyun_internal_url).to eq(@url.sub('oss-cn-hangzhou', 'oss-cn-hangzhou-internal')) }
    it { expect(@post.attachment.aliyun_alias_url).to eq(@url.sub('martin-test.oss-cn-hangzhou.aliyuncs.com', 'hackerpie.com')) }

    context 'use protocol relative url' do
      before(:all) {
        Paperclip::Attachment.default_options[:aliyun][:protocol_relative_url] = true
        @post.attachment.remove_instance_variable(:@oss_connection)
      }
      after(:all) {
        Paperclip::Attachment.default_options[:aliyun].delete :protocol_relative_url
        @post.attachment.remove_instance_variable(:@oss_connection)
      }
      before { @url = '//martin-test.oss-cn-hangzhou.aliyuncs.com/public/system/posts/attachments/000/000/001/original/girl.jpg' }

      protocol_relative_url = '//martin-test.oss-cn-hangzhou.aliyuncs.com/public/system/posts/attachments/000/000/001/original/girl.jpg'
      it { expect(@post.attachment.aliyun_upload_url).to eq(@url) }
      it { expect(@post.attachment.aliyun_external_url).to eq(@url) }
      it { expect(@post.attachment.aliyun_internal_url).to eq(@url.sub('oss-cn-hangzhou', 'oss-cn-hangzhou-internal')) }
      it { expect(@post.attachment.aliyun_alias_url).to eq(@url.sub('martin-test.oss-cn-hangzhou.aliyuncs.com', 'hackerpie.com')) }
    end
  end

  describe '#flush_writes' do
    it 'uploads the attachment to Aliyun' do
      response = open(@post.attachment.url)
      expect(response).to be_truthy
    end

    it 'get uploaded file from Aliyun' do
      attachment = open @post.attachment.url
      expect(attachment.size).to eq(@file.size)
    end

    it 'set content type according to the original file' do
      attachment = load_attachment('masu.pdf')
      post = Post.create attachment: attachment
      headers = RestClient.head(post.attachment.url).headers
      expect(headers[:content_type]).to eq('application/pdf')

      post.destroy
    end
  end

  describe '#exists?' do
    it 'returns true if the file exists on Aliyun' do
      expect(@post.attachment).to exist
    end

    it "returns false if the file doesn't exist on Aliyun" do
      post = Post.new attachment: @file
      expect(post.attachment).not_to exist
    end

    it 'not raise exception when attachment not saved' do
      post = Post.create
      expect { post.attachment.exists? }.not_to raise_error
    end
  end

  describe '#copy_to_local_file' do
    it 'copies file from Aliyun to a local file' do
      destination = File.join(Bundler.root, 'tmp/photo.jpg')
      @post.attachment.copy_to_local_file(:original, destination)
      expect(File.exist?(destination)).to be_truthy

      File.delete destination
    end
  end

  describe '#flush_deletes' do
    it 'deletes the attachment from Aliyun' do
      attachment_url = @post.attachment.url
      @post.destroy

      response_code = Net::HTTP.get_response(URI.parse(attachment_url)).code
      expect(response_code).to eq('404')
    end

    context "work with path include Chinese characters" do
      before do
        @file_with_chinese_char_name = load_attachment("美女.jpg")
        @post_with_chinese_char_name_file = Post.create attachment: @file_with_chinese_char_name
      end

      it "deletes the attachment from Aliyun" do
        attachment_url = @post_with_chinese_char_name_file.attachment.url
        @post_with_chinese_char_name_file.destroy
        response_code = Net::HTTP.get_response(URI.parse(attachment_url)).code
        expect(response_code).to eq('404')
      end
    end
  end
end
