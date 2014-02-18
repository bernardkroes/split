require 'spec_helper'
require 'split/counter'

describe Split::Counter do
  describe 'basic use' do
    it "should create a counter upon using it, if it does not exist" do
      counter1 = Split::Counter.new(:name => 'co')
      counter1.inc('exp1', 'alt1')
      counter1.current_value('exp1', 'alt1').should eq("1")
    end

    it "should create a counter directly upon using it, if it does not exist" do
      Split::Counter.inc('co','exp1', 'alt1')
      Split::Counter.current_value('co', 'exp1', 'alt1').should eq("1")
    end

    it "should not create a counter upon using it, if it does exist" do
      counter1 = Split::Counter.new(:name => 'co')
      counter1.inc('exp1', 'alt1')
      counter1.inc('exp1', 'alt1')
      counter2 = Split::Counter.new(:name => 'co') 
      counter2.current_value('exp1', 'alt1').should eq("2")
    end

    it "should be possible to increase a counter directly for an experiment and alternative" do
      counter1 = Split::Counter.new(:name => 'co')
      counter1.inc('exp1', 'alt1')
      Split::Counter.inc('co','exp1', 'alt1')
      counter1.current_value('exp1', 'alt1').should eq("2")
    end

    it "should be possible to get all experiments and hashs counter values" do
      counter1 = Split::Counter.new(:name => 'co')
      counter1.inc('exp1', 'alt1')
      counter1.inc('exp1', 'alt2')
      counter1.inc('exp1', 'alt2')
      Split::Counter.inc('co','exp2', 'alt1')
      counter1.all_values_hash
    end

    it "should be possible to get a list of all counters" do
      counter1 = Split::Counter.new(:name => 'co')
      counter1.inc('exp1', 'alt1')
      Split::Counter.inc('co2','exp2', 'alt1')
      puts Split::Counter.all_counter_names.inspect
    end
  end
end
