require 'aliyun/errors'

module Aliyun
  module DataCenter
    # https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region
    AVAILABLE_DATA_CENTERS = %w(
      oss-cn-hangzhou
      oss-cn-qingdao
      oss-cn-beijing
      oss-cn-hongkong
      oss-cn-shenzhen
      oss-cn-shanghai
      oss-us-west-1
      oss-ap-southeast-1
    )

    def get_endpoint(options)
      data_center = find_center(options[:data_center])

      unless data_center && AVAILABLE_DATA_CENTERS.include?(data_center)
        fail InvalildDataCenter, "Unsupported Data Center #{options[:data_center]} Detected"
      end

      "#{data_center}#{options[:internal] ? '-internal' : ''}.aliyuncs.com"
    end

    def find_center(data_center)
      return if /(oss|cn|us|ap|oss-cn)/.match(data_center)

      AVAILABLE_DATA_CENTERS.each do |center|
        return center if Regexp.new(data_center).match(center)
      end
    end
  end
end
