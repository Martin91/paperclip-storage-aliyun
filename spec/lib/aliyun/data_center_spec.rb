require 'spec_helper'
require 'aliyun/data_center'

include Aliyun::DataCenter

describe Aliyun::DataCenter do
    describe "#get_endpoint" do
        it "should not modify passed in options" do
            original_data_center = OSS_CONNECTION_OPTIONS[:data_center].dup
            endpoint = get_endpoint(OSS_CONNECTION_OPTIONS)

            expect(endpoint).to eq("oss-cn-hangzhou.aliyuncs.com")
            expect(OSS_CONNECTION_OPTIONS[:data_center]).to eq(original_data_center)
        end
    end
end