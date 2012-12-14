#encoing: utf-8
module Service
  module VoteService

    def self.is_liked? (voter, votable)
      result =  voter.voted_as_when_voted_for votable
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
        @votable.disliked_by @voter
      end
    end




  end
end