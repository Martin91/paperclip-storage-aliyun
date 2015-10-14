module Paperclip
  module Storage
    module Aliyun
      def self.extended(base)
        base.instance_eval do
          @aliyun_options = @options[:aliyun]
        end

        [
          :aliyun_upload_url,   :aliyun_internal_url,
          :aliyun_external_url, :aliyun_alias_url
        ].each do |url_style|
          Paperclip.interpolates(url_style) do |attachment, style|
            attachment.send(url_style, style)
          end unless Paperclip::Interpolations.respond_to? url_style
        end
      end

      def aliyun_upload_url(style = default_style)
        "http://#{oss_connection.aliyun_upload_host}/#{path(style).sub(%r{\A/}, '')}"
      end

      def aliyun_internal_url(style = default_style)
        "http://#{oss_connection.aliyun_internal_host}/#{path(style).sub(%r{\A/}, '')}"
      end

      def aliyun_external_url(style = default_style)
        "http://#{oss_connection.aliyun_external_host}/#{path(style).sub(%r{\A/}, '')}"
      end

      def aliyun_alias_url(style = default_style)
        "http://#{oss_connection.aliyun_alias_host}/#{path(style).sub(%r{\A/}, '')}"
      end

      def exists?(style = default_style)
        path(style) ? oss_connection.exists?(path(style)) : false
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style_name, file|
          oss_connection.put path(style_name), (File.new file.path), content_type: file.content_type
        end

        after_flush_writes

        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          oss_connection.delete path
        end

        @queued_for_delete = []
      end

      def copy_to_local_file(style, local_dest_path)
        log("copying #{path(style)} to local file #{local_dest_path}")
        local_file = ::File.open(local_dest_path, 'wb')
        remote_file_str = oss_connection.get path(style)
        local_file.write(remote_file_str)
        local_file.close
      end

      def oss_connection
        @oss_connection ||= ::Aliyun::Connection.new(
          Paperclip::Attachment.default_options[:aliyun].merge(@aliyun_options)
        )
      end
    end
  end
end
