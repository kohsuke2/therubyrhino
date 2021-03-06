require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Rhino::Ruby::AttributeAccess do
  
  before(:all) do
    Rhino::Ruby::Scriptable.access = Rhino::Ruby::AttributeAccess
  end
  
  after(:all) do
    Rhino::Ruby::Scriptable.access = nil
  end
  
  class Meh
    
    attr_reader :anAttr0
    attr_accessor :the_attr_1
    
    def initialize
      @anAttr0 = nil
      @the_attr_1 = 'attr_1'
      @an_attr_2 = 'attr_2'
    end
    
    def theMethod0; @theMethod0; end
    
    def a_method1; 1; end
    
    def the_method_2; '2'; end
    
  end
  
  it "gets methods and instance variables" do
    rb_object = Rhino::Ruby::Object.wrap Meh.new
    
    rb_object.get('anAttr0', nil).should be_nil
    rb_object.get('the_attr_1', nil).should == 'attr_1'
    rb_object.get('an_attr_2', nil).should be(Rhino::JS::Scriptable::NOT_FOUND) # no reader
    
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |name|
      rb_object.get(name, nil).should be_a(Rhino::Ruby::Function)
    end
    
    rb_object.get('non-existent-method', nil).should be(Rhino::JS::Scriptable::NOT_FOUND)
  end

  it "has methods and instance variables" do
    rb_object = Rhino::Ruby::Object.wrap Meh.new
    
    rb_object.has('anAttr0', nil).should be_true
    rb_object.has('the_attr_1', nil).should be_true
    rb_object.has('an_attr_2', nil).should be_false # no reader nor writer
    
    [ 'theMethod0', 'a_method1', 'the_method_2' ].each do |name|
      rb_object.has(name, nil).should be_true
    end
    
    rb_object.has('non-existent-method', nil).should be_false
  end
  
  it "puts using attr writer" do
    start = mock('start')
    start.expects(:put).never
    rb_object = Rhino::Ruby::Object.wrap Meh.new
    
    rb_object.put('the_attr_1', start, 42)
    rb_object.the_attr_1.should == 42
  end
  
end
