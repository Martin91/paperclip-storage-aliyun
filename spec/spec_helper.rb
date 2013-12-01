require 'pry'
require 'pry-nav'
require 'rspec/autorun'
require 'paperclip-storage-aliyun'

Dir[File.join(Bundler.root, "spec/support/**/*.rb")].each &method(:require)

include Paperclip::Storage::Aliyun
def file_host
  oss_connection.fetch_file_host
end

# paperclip初始化设置
Paperclip::Attachment.default_options[:storage] = :aliyun
Paperclip::Attachment.default_options[:path] = 'public/system/:class/:attachment/:id_partition/:style/:filename'
Paperclip::Attachment.default_options[:aliyun] = {
  access_id: '3VL9XMho8iCuslj8',
  access_key: 'VAUI2q7Tc6yTf1jr3kBsEUzZ84gEa2',
  bucket: 'martin-test',
  data_centre: 'hangzhou',
  internal: false
  # host: nil
}
Paperclip::Attachment.default_options[:url] = "http://#{file_host}/public/system/:class/:attachment/:id_partition/:style/:filename"

def load_attachment(file_name)
  File.open (File.expand_path "attachments/#{file_name}", File.dirname(__FILE__)), 'rb'
end
