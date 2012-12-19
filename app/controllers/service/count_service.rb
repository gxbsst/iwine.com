#encoing: utf-8
module Service
  module CountService

    class Count  # 赞

      def self.call(countable, &block)
        new(countable, block).counts
      end

      def initialize(countable, block)
        @countable = countable
        @block = block
      end

      def likes_count
        #Rails.cache.fetch ([@countable, :likes_counter]) do
          @countable.likes.size
        #end
      end

      def comments_count
        #Rails.cache.fetch ([@countable, :comments_counter]) do
          @countable.comments_count
        #end
      end

      def counts
        Counter.new(likes_count, comments_count)
      end

    end

    class Counter < Struct.new(:likes, :comments)

    end

  end
end