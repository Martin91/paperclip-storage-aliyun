require 'aliyun/errors'

module Aliyun
  module DataCenter
    # https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region
    AVAILABLE_DATA_CENTERS = %w(
      oss-cn-hangzhou
      oss-cn-shanghai
      oss-cn-qingdao
      oss-cn-beijing
      oss-cn-shenzhen
      oss-cn-hongkong
      oss-us-west-1
      oss-us-east-1
      oss-ap-southeast-1
      oss-ap-southeast-2
      oss-ap-northeast-1
      oss-eu-central-1
      oss-me-east-1
    )

    def get_endpoint(options)
      data_center = find_center(options[:data_center])

      unless data_center && AVAILABLE_DATA_CENTERS.include?(data_center)
        fail InvalildDataCenter, "Unsupported Data Center #{options[:data_center]} Detected"
      end

      "#{data_center}#{options[:internal] ? '-internal' : ''}.aliyuncs.com"
    end

    def find_center(data_center)
      return if /^(oss|cn|us|ap|oss-cn)$/.match(data_center)

      regexp = Regexp.new(data_center)
      AVAILABLE_DATA_CENTERS.find { |center| regexp.match(center) }
    end
  end
end
