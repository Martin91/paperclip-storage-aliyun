module Paperclip
  module Storage
    module Aliyun
      def self.extended(base)
      end

      def exists?(style = default_style)
        oss_connection.exists? path(style)
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
        return @oss_connection if @oss_connection

        @oss_connection ||= ::Aliyun::Connection.new
      end
    end
  end
end
