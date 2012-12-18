#encoing: utf-8
module Service
  module VoteService

    def self.is_liked? (voter, votable)
      #binding.pry
      result = Rails.cache.fetch([voter, votable, :liked]) do
       voter.voted_as_when_voted_for votable
      end
      result ? true : false
    end

    class Vote  # 赞
      def self.run(votable, voter)
        new(votable, voter).like
      end

      def initialize(votable, voter)
        @votable = votable
        @voter = voter
      end

      def like
        Rails.cache.delete([@voter, @votable, :liked])
        Rails.cache.delete([@votable, :likes_counter])
        @votable.like_by @voter
      end
    end

    class UnVote  # 取消赞
      def self.run(votable, voter)
        new(votable, voter).unlike
      end

      def initialize(votable, voter)
        @votable = votable
        @voter = voter
      end

      def unlike
        Rails.cache.delete([@voter, @votable, :liked])
        Rails.cache.delete ([@votable, :likes_counter])
        @votable.disliked_by @voter
      end
    end

  end
end