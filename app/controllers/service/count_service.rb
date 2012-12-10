#encoing: utf-8
module Service
  module CountService

    class Count  # 赞

      def self.call(countable)
        new(countable).counts
      end

      def initialize(countable)
        @countable = countable
      end

      def followers_count
        @countable.followers_count
      end

      def likes_count
        @countable.likes.size
      end

      def comments_count
        @countable.comments_count
      end

      def counts
        Counter.new(followers_count, likes_count, comments_count)
      end

    end

    class Counter < Struct.new(:followers_count, :likes_count, :comments_count)

    end

  end
end