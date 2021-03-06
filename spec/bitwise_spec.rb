# Tests for the bitwise / bitmask functionality.

require 'spec_helper'
require 'maintain'

describe Maintain do
  before :each do
    class ::MaintainTest
      extend Maintain
    end
  end

  describe "bitmask", "class methods" do
    it "should allow multiple defaults" do
      MaintainTest.maintain :permissions, :bitmask => true do
        state :edit, 1, :default => true
        state :delete, 2, :default => true
        state :update, 3
      end
      @maintainer = MaintainTest.new
      @maintainer.permissions.edit?.should be_true
      @maintainer.permissions.delete?.should be_true
      @maintainer.permissions.update?.should_not be_true
    end
  end

  describe "bitmask", "instance methods" do
    before :each do
      MaintainTest.maintain :permissions, :bitmask => true do
        state :edit, 1
        state :delete, 2
        state :update, 3
      end
      @maintainer = MaintainTest.new
    end

    describe "accessor methods" do
      it "should default to zero" do
        maintainer = MaintainTest.new
        maintainer.permissions.should == 0
      end

      it "should be able to test values" do
        maintainer = MaintainTest.new
        maintainer.permissions = :edit
        maintainer.permissions.edit?.should be_true
        maintainer.permissions.delete?.should_not be_true
        maintainer.permissions = [:update, :delete]
        maintainer.permissions.edit?.should_not be_true
        maintainer.permissions.delete?.should be_true
        maintainer.permissions.update?.should be_true
      end

      it "should be able to test values directly on the class" do
        maintainer = MaintainTest.new
        maintainer.permissions = :edit
        maintainer.edit?.should be_true
        maintainer.delete?.should_not be_true
      end

      it "should not trap every method" do
        maintainer = MaintainTest.new
        lambda {
          maintainer.permissions.foobar?
        }.should raise_error(NoMethodError)
      end

      it "should be enumerable" do
        maintainer = MaintainTest.new
        maintainer.permissions = %w(edit update)
        maintainer.permissions.to_a.should == %w(edit update).map(&:to_sym)
        maintainer.permissions.should respond_to(:each)
        maintainer.permissions.select {|permission| permission == :edit}.should == [:edit]
      end
    end

    describe "setter methods" do
      it "should be able to set values on the whole field" do
        @maintainer.permissions = :edit
        @maintainer.permissions.should == [:edit]
        @maintainer.permissions.should == 2
      end

      it "should be able to set values as an array" do
        @maintainer.permissions = [:edit, :delete]
        @maintainer.permissions.should == 6
        @maintainer.permissions.should_not == 7
        @maintainer.permissions.should == [:edit, :delete]
      end

      it "should be able to set individual bitmask values" do
        @maintainer.permissions = nil
        @maintainer.permissions = []
        @maintainer.permissions.should == 0
        @maintainer.permissions.edit!
        @maintainer.permissions.edit?.should be_true
        @maintainer.permissions.delete?.should_not be_true
        @maintainer.permissions.update!
        @maintainer.permissions.edit?.should be_true
        @maintainer.permissions.edit?.should be_true
        @maintainer.permissions.delete?.should_not be_true
        @maintainer.permissions.update?.should be_true
      end
    end
  end
end
