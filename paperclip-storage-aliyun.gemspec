Gem::Specification.new do |s|
  s.name         = 'paperclip-storage-aliyun'
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.summary      = 'Extend a Aliyun OSS storage for paperclip'
  s.description  = 'Extend a Aliyun OSS storage for paperclip'
  s.version      = '0.0.1'
  s.files        = `git ls-files`.split("\n")
  s.authors      = ['Martin Hong']
  s.email        = 'hongzeqin@gmail.com'
  s.homepage     = 'https://github.com/Martin91/paperclip-storage-aliyun'
  s.license      = 'MIT'
  # s.test_files   = ''

  s.add_runtime_dependency 'paperclip', '>= 3.5.2'
  s.add_runtime_dependency 'rest-client', '>= 1.6.7'
end
