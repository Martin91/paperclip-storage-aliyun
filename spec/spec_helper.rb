require 'pry'
require 'pry-nav'
require 'paperclip-storage-aliyun'

Paperclip.logger.level = ::Logger::UNKNOWN
Dir[Bundler.root.join('spec/support/**/*.rb')].each(&method(:require))

# Aliyun defaults
OSS_CONNECTION_OPTIONS = {
  access_id: ENV['OSS_ACCESS_ID'],
  access_key: ENV['OSS_ACCESS_KEY'],
  bucket: 'martin-test',
  data_center: 'cn-hangzhou',
  internal: false
  # host_alias: nil
}

# Paperclip defaults
Paperclip::Attachment.default_options[:storage] = :aliyun
Paperclip::Attachment.default_options[:aliyun] = OSS_CONNECTION_OPTIONS
Paperclip::Attachment.default_options[:path] = 'public/system/:class/:attachment/:id_partition/:style/:filename'
Paperclip::Attachment.default_options[:url] = ':aliyun_upload_url'

# Utility methods
def load_attachment(file_name)
  File.open(Bundler.root.join("spec/attachments/#{file_name}"), 'rb')
end
