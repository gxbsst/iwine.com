require 'spec_helper'

describe Notes::NoteAgent do
  before(:each) do
   @response =  Notes::NoteAgent.get(:path => '/iwinenotes/iwine/detail/FE0F09F8-B395-4C8A-82EC-0A2A028127B2')
  end

  it "item size should > 1" do
    parsed_body = JSON.parse(@response.body)
    parsed_body.should include("Rosstal")
  end

end
