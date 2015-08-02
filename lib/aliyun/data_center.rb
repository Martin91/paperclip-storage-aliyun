require 'aliyun/errors'

module Aliyun
	module DataCenter
		# https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region
    AVAILABLE_CHINA_DATA_CENTERS = %w(hangzhou qingdao beijing hongkong shenzhen shanghai)
    AVAILABLE_US_DATA_CENTERS = %w(us-west-1)

    def get_endpoint(options)
    	data_center = options[:data_center]
    	if (AVAILABLE_CHINA_DATA_CENTERS + AVAILABLE_US_DATA_CENTERS).exclude?(data_center)
    		raise InvalildDataCenter, "Unsupported Data Center #{data_center} Detected"
    	end

    	internal = options[:internal] ? "-internal" : ''
    	country = AVAILABLE_CHINA_DATA_CENTERS.include?(data_center) ? 'cn' : 'us'
    	"oss-#{country}-#{data_center}#{internal}.aliyuncs.com"
    end
	end
end