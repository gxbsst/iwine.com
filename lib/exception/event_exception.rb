module EventException

  class HaveFollowedEvent < RuntimeError
  end

  class HaveNoFollowedEvent < RuntimeError
  end

  class HaveJoinedEvent < RuntimeError
  end

  class HaveNoJoinedEvent < RuntimeError
  end

  class ErrorPeopleNum < Exception
  end

  class EventHaveCancled < Exception

  end

  class EventHavePublished < Exception

  end

end
