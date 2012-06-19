# Counter

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'counter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install counter

## Usage

注意(重要):
 increment 和 decrement 的on 不能一样，即不能同时为: on => :after, 否则会覆盖
 
:with 要监控的对象名称，为Class Name， 如Comment
:receiver 当with对象发生变化， count发生变化的对象, 如Detail
:increment ＋1
  :on 为callback方法， 如save
  :if 为 执行这个callback的条件， 返回true才执行
:decrement -1
 :on 为callback方法， 如save
 :if 为 执行这个callback的条件， 返回true才执行

counts  :photos_count   => {:with => "AuditLog",
                            :receiver => lambda {|audit_log| audit_log.logable.imageable }, 
                            :increment => {:on => :create, :if => lambda {|audit_log| audit_log.owner_type == OWNER_TYPE_PHOTO && audit_log.counts_should_increment? }},
                            :decrement => {:on => :save, :if => lambda {|audit_log| audit_log.owner_type == OWNER_TYPE_PHOTO && audit_log.counts_should_decrement? }}                              
                           },              
        :comments_count => {:with => "Comment", 
                           :receiver => lambda {|comment| comment.commentable },
                           :increment => {:on => :create, :if => lambda {|comment| comment.commentable_type == "Wines::Detail" && comment.do == "comment"}},
                           :decrement => {:on => :save,   :if => lambda {|comment| comment.commentable_type == "Wines::Detail" && comment.do == "comment" && !comment.deleted_at.blank?}}                              
                           },
       :followers_count => {:with => "Comment", 
                            :on => :create,
                            :receiver => lambda {|comment| comment.commentable },
                            :increment => {:on => :create, :if => lambda {|comment| comment.commentable_type == "Wines::Detail" && comment.do == "follow"}},
                            :decrement => {:on => :save,   :if => lambda {|comment| comment.commentable_type == "Wines::Detail" && comment.do == "follow" && !comment.deleted_at.blank?}}                              
                            },
         :owners_count  =>  {:with => "Users::WineCellarItem",
                            :receiver => lambda {|cellar_item| cellar_item.wine_detail},
                            :increment => {:on => :create},
                            :decrement => {:on => :destroy}
                           }       

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
