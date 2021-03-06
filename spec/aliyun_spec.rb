require 'spec_helper'

require 'net/http'

describe Aliyun::Connection do
  before :all do
    @connection = ::Aliyun::Connection.new OSS_CONNECTION_OPTIONS
    @path = 'a/a.jpg'
  end

  describe '#initialize' do
    it 'raise error when use invalid data center' do
      expect do
        ::Aliyun::Connection.new data_center: 'guangzhou'
      end.to raise_error(Aliyun::InvalildDataCenter)
    end

    it 'raises an error when using ambiguous data center' do
      expect do
        ::Aliyun::Connection.new data_center: 'hangzhou'
      end.to raise_error(Aliyun::InvalildDataCenter)
    end
  end

  describe '#put' do
    it 'upload the attachment' do
      url = @connection.put @path, load_attachment('girl.jpg')
      response_code = Net::HTTP.get_response(URI.parse(url)).code
      expect(response_code).to eq('200')
    end

    it 'support setting content type' do
      content_type = 'application/pdf'
      path = 'pdfs/masu.pdf'
      @connection.put path, load_attachment('masu.pdf'), content_type: content_type
      file_meta = @connection.head(path)
      expect(file_meta[:content_type]).to eq(content_type)

      @connection.delete path
    end
  end

  describe '#delete' do
    it 'delete the attachment' do
      url = @connection.delete @path
      response_code = Net::HTTP.get_response(URI.parse(url)).code
      expect(response_code).to eq('404')
    end

    describe "delete attachment with Chinese name" do
      it "delete the attachment" do
        path = "a/美女.jpg"
        @connection.put path, load_attachment('美女.jpg')
        url = @connection.delete path
        response_code = Net::HTTP.get_response(URI.parse(url)).code
        expect(response_code).to eq('404')
      end
    end
  end

  describe '#head' do
    it 'return headers for uploaded file' do
      @connection.put @path, load_attachment('girl.jpg')
      expect(@connection.head(@path)).not_to be_empty
    end
  end

  describe '#exists?' do
    before :all do
      @connection.put @path, load_attachment('girl.jpg')
      @path_include_chinese = "美女.jpg"
      @connection.put @path_include_chinese, load_attachment("美女.jpg")
    end

    it 'return true if the file has been uploaded' do
      expect(@connection.exists?(@path)).to be_truthy
    end

    it "return false if the specified file didn't exist" do
      @connection.delete @path
      expect(@connection.exists?(@path)).to be_falsey
    end

    it "also return true for existed file with path include chinese characters" do
      expect(@connection.exists?(@path_include_chinese)).to be_truthy
      @connection.delete @path_include_chinese
    end
  end
end
