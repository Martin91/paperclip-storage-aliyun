# encoding: utf-8

require 'openssl'
require 'digest/md5'
require 'rest-client'
require 'base64'
require 'uri'
require 'aliyun/data_center'

module Aliyun
  class Connection
    include DataCenter

    # The upload host according to the connection configurations
    attr_reader :aliyun_upload_host
    # The internal host
    attr_reader :aliyun_internal_host
    # The external host
    attr_reader :aliyun_external_host
    # The alias host
    attr_reader :aliyun_alias_host

    # Initialize the OSS connection
    #
    # @param [Hash] An options to specify connection details
    # @option access_id [String] used to set "Authorization" request header
    # @option access_key [String] the access key
    # @option bucket [String] bucket used to access
    # @option data_center [String] available data center name, e.g. 'hangzhou'
    # @option internal [true, false] if the service should be accessed through internal network
    # @option host_alias [String] the alias of the host, such as the CDN domain name
    # @note both access_id and acces_key are related to authorization algorithm:
    #   https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-header
    def initialize(options = {})
      @aliyun_access_id = options[:access_id]
      @aliyun_access_key = options[:access_key]
      @aliyun_bucket = options[:bucket]

      @aliyun_upload_host = "#{@aliyun_bucket}.#{get_endpoint(options)}"
      @aliyun_internal_host = "#{@aliyun_bucket}.#{get_endpoint(options.merge(internal: true))}"
      @aliyun_external_host = "#{@aliyun_bucket}.#{get_endpoint(options.merge(internal: false))}"
      @aliyun_alias_host = options[:host_alias] || @aliyun_upload_host
    end

    # Return the meta informations for the a file specified by the path
    # https://docs.aliyun.com/#/pub/oss/api-reference/object&HeadObject
    #
    # @param path [String] the path of file storaged in Aliyun OSS
    # @return [Hash] the meta data of the file
    # @note the example headers will be like:
    #
    #   {
    #    {:date=>"Sun, 02 Aug 2015 02:42:45 GMT",
    #    :content_type=>"image/jpg",
    #    :content_length=>"125198",
    #    :connection=>"close",
    #    :accept_ranges=>"bytes",
    #    :etag=>"\"336262A42E5B99AFF5B8BC66611FC156\"",
    #    :last_modified=>"Sun, 01 Dec 2013 16:39:57 GMT",
    #    :server=>"AliyunOSS",
    #    :x_oss_object_type=>"Normal",
    #    :x_oss_request_id=>"55BD83A5D4C05BDFF4A329E0"}}
    #
    def head(path)
      url = path_to_url(path)
      RestClient.head(url).headers
    rescue RestClient::ResourceNotFound
      {}
    end

    # Upload File to Aliyun OSS
    # https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject
    #
    # @param path [String] the target storing path on the oss
    # @param file [File] an instance of File represents a file to be uploaded
    # @param options [Hash]
    #   - content_type - MimeType value for the file, default is "image/jpg"
    #
    # @return [String] The downloadable url of the uploaded file
    # @return [nil] if the uploading failed
    def put(path, file, options = {})
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      content_md5 = Digest::MD5.file(file)
      content_type = options[:content_type] || 'image/jpg'
      date = gmtdate
      url = path_to_url(path)
      auth_sign = sign('PUT', bucket_path, content_md5, content_type, date)
      headers = {
        'Authorization' => auth_sign,
        'Content-Type' => content_type,
        'Content-Length' => file.size,
        'Date' => date,
        'Host' => @aliyun_upload_host,
        'Expect' => '100-Continue'
      }
      response = RestClient.put(URI.encode(url), file, headers)
      response.code == 200 ? path_to_url(path) : nil
    end

    # Delete a file from the OSS
    # https://docs.aliyun.com/#/pub/oss/api-reference/object&DeleteObject
    #
    # @param path [String] the path to retrieve the file on remote storage
    # @return [String] the expired url to the file, if the file deleted successfully
    # @return [nil] if the delete operation failed
    def delete(path)
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      date = gmtdate
      headers = {
        'Host' => @aliyun_upload_host,
        'Date' => date,
        'Authorization' => sign('DELETE', bucket_path, '', '', date)
      }
      url = path_to_url(path)
      response = RestClient.delete(URI.encode(url), headers)
      response.code == 204 ? url : nil
    end

    # Download the file from OSS
    # https://docs.aliyun.com/#/pub/oss/api-reference/object&GetObject
    #
    # @param path [String] the path to retrieve the file on remote storage
    # @return [?] the file content consist of bytes
    def get(path)
      path = format_path(path)
      bucket_path = get_bucket_path(path)
      date = gmtdate
      headers = {
        'Host' => @aliyun_upload_host,
        'Date' => date,
        'Authorization' => sign('GET', bucket_path, '', '', date)
      }
      url = path_to_url(path)
      response = RestClient.get(URI.encode(url), headers)
      response.body
    end

    # Determine if the file exists on the OSS
    # https://docs.aliyun.com/#/pub/oss/api-reference/object&HeadObject
    #
    # @param path [String] the path to retrieve the file on remote storage
    # @return [true] if file exists
    # @return [false] if file could not be found
    def exists?(path)
      head(path).empty? ? false : true
    end

    # The GMT format time referenced from HTTP 1.1
    # https://docs.aliyun.com/#/pub/oss/api-reference/public-header
    #
    # @return [String] a string represents the formated time, e.g. "Wed, 05 Sep. 2012 23:00:00 GMT"
    def gmtdate
      Time.now.gmtime.strftime('%a, %d %b %Y %H:%M:%S GMT')
    end

    # remove leading slashes in the path
    #
    # @param path [String] the path to retrieve the file on remote storage
    # @return [String] the new string after removing leading slashed
    def format_path(path)
      return '' if path.blank?
      path.gsub!(%r{^/+}, '')

      path
    end

    # A path consis of the bucket name and file name
    # https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-header
    #
    # @param path [String] the path to retrieve the file on remote storage
    # @return [String] the expected bucket path, e.g. "test-bucket/oss-api.pdf"
    def get_bucket_path(path)
      [@aliyun_bucket, path].join('/')
    end

    # The full path contains host name to the file
    #
    # @param path [String] the path to retrieve the file on remote storage
    # @return [String] the expected full path, e.g. "http://martin-test.oss-cn-hangzhou.aliyuncs.com/oss-api.pdf"
    def path_to_url(path)
      path =~ %r{^https?:\/{2}} ? path : "http://#{aliyun_upload_host}/#{path}"
    end

    private

    # The signature algorithm
    # https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-header
    #
    # @param verb [String] the request verb, e.g. "GET" or "DELETE"
    # @param content_md5 [String] the md5 value for the content to be uploaded
    # @param content_type [String] the content type of the file, e.g. "application/pdf"
    # @param date [String] the GMT formatted date string
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
