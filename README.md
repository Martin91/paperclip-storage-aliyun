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
  data_center: 'cn-hangzhou',
  internal: false,
  protocol: 'https'
}
```
Then, in the model which defines the attachment, specify your storage and other options, for example:
```ruby
# [rails_root]/app/models/image.rb
class Image < ActiveRecord::Base
  has_attached_file :attachment, {
    storage: :aliyun,
    styles: { thumbnail: "60x60#"},
    path: 'public/system/:class/:attachment/:id_partition/:style/:filename',
    url: ':aliyun_upload_url'
  }
end
```

Similar to Paperclip::Storage::S3, there are four options for the url by now:
- `:aliyun_upload_url` : the url based on the options you give
- `:aliyun_internal_url` : the internal url, no matter what `options[:aliyun][:internal]` is
- `:aliyun_external_url` : the external url, no matter what `options[:aliyun][:internal]` is
- `:aliyun_alias_url` : the alias url based on the `host_alias` you give, typically used together with CDN

Please note the values above are all strings, not symbols. You could still make your own url if only you know what you are doing.

#### Data Centers
A list of available regions can be found at [https://intl.aliyun.com/help/doc-detail/31837.htm](https://intl.aliyun.com/help/doc-detail/31837.htm).
You can use the "Region Expression" column value as it is for the data center, or you can remove the "oss-" prefix. For example: `oss-cn-hangzhou` and `cn-hangzhou` are both valid options.

#### Test
1. Update connection settings in `spec/spec_helper.rb`:

  ```ruby
  # Aliyun defaults
  OSS_CONNECTION_OPTIONS = {
    access_id: 'your_access_key_id',
    access_key: 'your_access_key_secret',
    bucket: 'your_bucket',
    data_center: 'your_data_center',
    internal: false,
    protocol: 'https'
  }
  ```

2. Run `bundle exec rspec spec`.
