require 'rspec/autorun'
require 'paperclip-storage-aliyun'

# Config aliyun OSS certificate for Paperclip
Paperclip::Attachment.default_options[:aliyun] = {
  access_id: '3VL9XMho8iC',
  access_key: 'VAUIc6yTf1jr3kBsEUzZ84gEa2',
  bucket: 'test',
  data_centre: 'hangzhou', #TODO: use full link here
  internal: false,
  # host: nil
}

def load_attachment(file_name)
  File.open (File.expand_path "attachments/#{file_name}", File.dirname(__FILE__)), 'rb'
end
