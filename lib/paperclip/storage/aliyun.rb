module Paperclip
  module Storage
    module Aliyun
      def self.extended(base)
        Paperclip.interpolates(:aliyun_path_url) do |attachment, style|
          "http://#{attachment.oss_connection.fetch_file_host}/#{attachment.path(style).gsub(%r{\A/}, "")}"
        end unless Paperclip::Interpolations.respond_to? :aliyun_path_url
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

      def copy_to_local_file(style = default_style, local_dest_path)
        log("copying #{path(style)} to local file #{local_dest_path}")
        local_file = ::File.open(local_dest_path, 'wb')
        remote_file_str = oss_connection.get path(style)
        local_file.write(remote_file_str)
        local_file.close
      end

      def oss_connection
        @oss_connection ||= ::Aliyun::Connection.new Paperclip::Attachment.default_options[:aliyun]
      end
    end
  end
end
