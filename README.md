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
  data_centre: 'hangzhou',
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

### Thanks
这个gem是在参考[Jason Lee](https://github.com/huacnlee)先生写的gem [carrierwave-aliyun](https://github.com/huacnlee/carrierwave-aliyun)的基础上写出来的，其中主要直接用了阿里云接口的代码以及对应的测试代码，在此基础上自行实现Paperclip必要的`get`方法以及`exists?`方法。在此特别感谢**Jason Lee**先生的开源代码。
