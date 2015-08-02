Aliyun Open Storage Service for Paperclip
===
This gem implement the support for [Aliyun open storage service(OSS)](http://oss.aliyun.com) to [Paperclip](https://github.com/thoughtbot/paperclip).

#### Installation
```shell
gem install paperclip-storage-aliyun
```
Or, if you are using a bundler, you can append the following line into your **Gemfile**:
```ruby
gem 'paperclip-storage-aliyun'
```

#### Configuration
In order to make all the things work, you should do some important configurations through a initializer:

If you are developing a Rails application, you can append a new initializer like:
```ruby
# [rails_root]/config/initializers/paperclip-aliyun-configuration.rb
Paperclip::Attachment.default_options[:aliyun] = {
  access_id: '3VL9XMho8iCushj8',
  access_key: 'VAUI2q7Tc6yTh1jr3kBsEUzZ84gEa2',
  bucket: 'xx-test',
  data_center: 'hangzhou',
  internal: false
}
```
Then, in the model which defines the attachment, specify your storage and other options, for example:
```ruby
# [rails_root]/app/models/image.rb
include Paperclip::Storage::Aliyun

class Image < ActiveRecord::Base
  has_attached_file :attachment, {
    storage: :aliyun,
    styles: { thumbnail: "60x60#"},
    path: 'public/system/:class/:attachment/:id_partition/:style/:filename',
    url: "http://#{oss_connection.fetch_file_host}/public/system/:class/:attachment/:id_partition/:style/:filename"
  }
end
```