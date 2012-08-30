module EventException

  class HaveFollowedEvent < RuntimeError
  end

  class HaveNoFollowedEvent < RuntimeError
  end

  class HaveJoinedEvent < RuntimeError
  end

  class HaveNoJoinedEvent < RuntimeError
  end
    
end
