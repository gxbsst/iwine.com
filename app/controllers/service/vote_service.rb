#encoing: utf-8
module Service
  module VoteService

    def self.is_liked? (voter, votable, &block)
      #binding.pry
      #result = Rails.cache.fetch([voter, votable, :liked]) do
      result = voter.voted_as_when_voted_for votable
      #end
      block.call(voter, votable) if block
      result ? true : false
    end

    class Vote  # 赞
      def self.run(votable, voter, &block)
        new(votable, voter, block).like
      end

      def initialize(votable, voter, block)
        @votable = votable
        @voter = voter
        @block = block
      end

      def like
        #binding.pry
        #Rails.cache.delete([@voter, @votable, :liked])
        #Rails.cache.delete([@votable, :likes_counter])
        @votable.like_by @voter
        @block.call(voter, votable) if @block
      end
    end

    class UnVote  # 取消赞
      def self.run(votable, voter, &block)
        new(votable, voter, block).unlike
      end

      def initialize(votable, voter, block)
        @votable = votable
        @voter = voter
        @block = block
      end

      def unlike
        #binding.pry
        #Rails.cache.delete([@voter, @votable, :liked])
        #Rails.cache.delete ([@votable, :likes_counter])
        @votable.disliked_by @voter
        @block.call(voter, votable) if @block
      end
    end

  end
end