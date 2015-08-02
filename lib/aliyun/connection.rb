# encoding: utf-8

require 'openssl'
require 'digest/md5'
require "rest-client"
require "base64"
require 'uri'

module Aliyun
  class Connection
    def initialize(options = Paperclip::Attachment.default_options[:aliyun])
      @aliyun_access_id = options[:access_id]
      @aliyun_access_key = options[:access_key]
      @aliyun_bucket = options[:bucket]

      data_centre = options[:data_centre].to_s.downcase == 'qingdao' ? 'qingdao' : 'hangzhou'
      internal = options[:internal] == true ? true : false
      @aliyun_data_centre = "oss-cn-#{data_centre}#{internal ? '-internal' : nil}.aliyuncs.com"

      @aliyun_upload_host = "#{@aliyun_bucket}.#{@aliyun_data_centre}"

      @aliyun_host = options[:host] || @aliyun_upload_host
    end

    def fetch_file_host
      @aliyun_host
    end

    # Return the meta informations for the a file specified by the url
    # https://docs.aliyun.com/#/pub/oss/api-reference/object&HeadObject
    #
    # @param url [String] the url of file storaged in Aliyun OSS
    # @return [Hash] the meta data of the file
    # @note the example headers will be like:
    #    {:date=>"Sun, 02 Aug 2015 02:42:45 GMT",
    #     :content_type=>"image/jpg",
    #     :content_length=>"125198",
    #     :connection=>"close",
    #     :accept_ranges=>"bytes",
    #     :etag=>"\"336262A42E5B99AFF5B8BC66611FC156\"",
    #     :last_modified=>"Sun, 01 Dec 2013 16:39:57 GMT",
    #     :server=>"AliyunOSS",
    #     :x_oss_object_type=>"Normal",
    #     :x_oss_request_id=>"55BD83A5D4C05BDFF4A329E0"}
    #
    def head(url)
      RestClient.head(url).headers
    rescue RestClient::ResourceNotFound
      {}
    end

=begin rdoc
上传文件

== 参数:
- path - remote 存储路径
- file - 需要上传文件的 File 对象
- options:
  - content_type - 上传文件的 MimeType，默认 `image/jpg`

== 返回值:
图片的下载地址
=end
    def put(path, file, options={})
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      content_md5 = Digest::MD5.file(file)
      content_type = options[:content_type] || "image/jpg"
      date = gmtdate
      url = path_to_url(path)
      auth_sign = sign("PUT", bucket_path, content_md5, content_type, date)
      headers = {
        "Authorization" => auth_sign,
        "Content-Type" => content_type,
        "Content-Length" => file.size,
        "Date" => date,
        "Host" => @aliyun_upload_host,
        "Expect" => "100-Continue"
      }
      response = RestClient.put(URI.encode(url), file, headers)
      response.code == 200 ? path_to_url(path) : nil
    end

=begin rdoc
删除 Remote 的文件

== 参数:
- path - remote 存储路径

== 返回值:
图片的下载地址
=end
    def delete(path)
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      date = gmtdate
      headers = {
        "Host" => @aliyun_upload_host,
        "Date" => date,
        "Authorization" => sign("DELETE", bucket_path, "", "" ,date)
      }
      url = path_to_url(path)
      response = RestClient.delete(URI.encode(url), headers)
      response.code == 204 ? url : nil
    end

=begin rdoc
下载 Remote 的文件

== 参数:
- path - remote 存储路径

== 返回值:
请求的图片的数据流
=end
    def get(path)
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      date = gmtdate
      headers = {
        "Host" => @aliyun_upload_host,
        "Date" => date,
        "Authorization" => sign("GET", bucket_path, "", "" ,date)
      }
      url = path_to_url(path)
      response = RestClient.get(URI.encode(url), headers)
      response.body
    end

=begin rdoc
检查远程服务器是否已存在指定文件

== 参数:
- path - remote 存储路径

== 返回值:
true/false
=end
    def exists?(path)
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      date = gmtdate
      headers = {
        "Host" => @aliyun_upload_host,
        "Date" => date,
        "Authorization" => sign("HEAD", bucket_path, "", "", date)
      }
      url = path_to_url(path)

      # rest_client will throw exception if requested resource not found
      begin
        response = RestClient.head(URI.encode(url), headers)
      rescue RestClient::ResourceNotFound
        return false
      end

      true
    end

    ##
    # 阿里云需要的 GMT 时间格式
    def gmtdate
      Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
    end

    def format_path(path)
      return "" if path.blank?
      path.gsub!(/^\/+/,"")

      path
    end

    def get_bucket_path(path)
      [@aliyun_bucket,path].join("/")
    end

    ##
    # 根据配置返回完整的上传文件的访问地址
    def path_to_url(path)
      "http://#{fetch_file_host}/#{path}"
    end

    private
    def sign(verb, path, content_md5 = '', content_type = '', date)
      canonicalized_oss_headers = ''
      canonicalized_resource = "/#{path}"
      string_to_sign = "#{verb}\n\n#{content_type}\n#{date}\n#{canonicalized_oss_headers}#{canonicalized_resource}"
      digest = OpenSSL::Digest.new('sha1')
      h = OpenSSL::HMAC.digest(digest, @aliyun_access_key, string_to_sign)
      h = Base64.encode64(h)
      "OSS #{@aliyun_access_id}:#{h}"
    end
  end
end
