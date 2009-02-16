require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/bricks/edit.html.erb" do
  include BricksHelper
  
  before(:each) do
    assigns[:brick] = @brick = stub_model(Brick,
      :new_record? => false,
      :value => 1,
      :name => "value for name",
      :email => "value for email",
      :url => "value for url",
      :message => "value for message"
    )
  end

  it "should render edit form" do
    render "/bricks/edit.html.erb"
    
    response.should have_tag("form[action=#{brick_path(@brick)}][method=post]") do
      with_tag('input#brick_value[name=?]', "brick[value]")
      with_tag('input#brick_name[name=?]', "brick[name]")
      with_tag('input#brick_email[name=?]', "brick[email]")
      with_tag('input#brick_url[name=?]', "brick[url]")
      with_tag('input#brick_message[name=?]', "brick[message]")
    end
  end
end

