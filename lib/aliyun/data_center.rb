require 'aliyun/errors'

module Aliyun
  module DataCenter
    # https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region
    AVAILABLE_DATA_CENTERS = %w(
      oss-cn-hangzhou
      oss-cn-shanghai
      oss-cn-qingdao
      oss-cn-beijing
      oss-cn-zhangjiakou
      oss-cn-huhehaote
      oss-cn-shenzhen
      oss-cn-hongkong
      oss-us-west-1
      oss-us-east-1
      oss-ap-southeast-1
      oss-ap-southeast-2
      oss-ap-southeast-3
      oss-ap-southeast-5
      oss-ap-northeast-1
      oss-ap-south-1
      oss-eu-central-1
      oss-eu-west-1
      oss-me-east-1
    )

    def get_endpoint(options)
      data_center = options[:data_center]

      data_center.prepend('oss-') unless data_center.match(/^oss/)

      unless AVAILABLE_DATA_CENTERS.include?(data_center)
        fail InvalildDataCenter, "Unsupported Data Center #{options[:data_center]} Detected"
      end

      "#{data_center}#{options[:internal] ? '-internal' : ''}.aliyuncs.com"
    end
  end
end
