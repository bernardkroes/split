module Split
  class Counter
    attr_accessor :name

    def initialize(attrs = {})
      attrs.each do |key,value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        end
      end
    end

    def hash_name
      "co:#{name}"
    end

    def self.hash_name_for_name(in_name)
      "co:#{in_name}"
    end

    def self.keyname_for_experiment_and_alternative(experiment, alternative)
      [experiment.gsub(":", ""), alternative.gsub(":", "")].join(':')
    end

    def self.inc(name, experiment, alternative)
      Split.redis.hincrby(self.hash_name_for_name(name), self.keyname_for_experiment_and_alternative(experiment, alternative), 1)
    end

    def inc(experiment, alternative)
      Split.redis.hincrby(hash_name, self.keyname_for_experiment_and_alternative(experiment, alternative), 1)
    end

    def self.current_value(name, experiment, alternative)
      Split.redis.hget(self.hash_name_for_name(name), self.keyname_for_experiment_and_alternative(experiment, alternative))
    end

    def current_value(experiment, alternative)
      Split.redis.hget(hash_name, self.keyname_for_experiment_and_alternative(experiment, alternative))
    end

    # TODO add: reset the entire counter 
    # TODO add: reset an experiment
    def reset(experiment, alternative)
      Split.redis.hdel(:counters, self.keyname_for_experiment_and_alternative(experiment, alternative))
    end

    def all_values_hash
      return_hash = {}
      result_hash = Split.redis.hgetall(hash_name)  # {"exp1:alt1"=>"1", "exp1:alt2"=>"2", "exp2:alt1"=>"1", "exp2:alt2"=>"2"}
      result_hash.each do |key, value| 
        experiment, alternative = key.split(":")
        return_hash[experiment] ||= Hash.new
        return_hash[experiment].merge!({ alternative => value.to_i })
      end
      return_hash
    end

    def self.all_values_hash(name)
      return_hash = {}
      result_hash = Split.redis.hgetall(self.hash_name_for_name(name))  # {"exp1:alt1"=>"1", "exp1:alt2"=>"2", "exp2:alt1"=>"1", "exp2:alt2"=>"2"}
      result_hash.each do |key, value| 
        experiment, alternative = key.split(":")
        return_hash[experiment] ||= Hash.new
        return_hash[experiment].merge!({ alternative => value.to_i })
      end
      return_hash
    end

    def self.all_counter_names
      Split.redis.keys("co:*").collect { |k| k.gsub(/^.*:/,"") }
    end
  end
end

__END__

counters:  {  
  'clickout' : 
      { 
        'cctv' 
        {
          'o' : 1,
          'g' : 2,
        },
        'experiment2' 
        {
          'alternative1' : 1,
          'alternative2' : 2,
        }
      },
  'couponclickout' :
      {
        'cctv' 
        {
          'o' : 111,
          'g' : 112,
        },
        'experiment2' 
        {
          'alternative1' : 2011,
          'alternative2' : 2012,
        }
      },


clickout: 
{
  'cctv:o': 1,
  'cctv:g': 2,
  'experiment2:alternative1' : 1,
  'experiment2:alternative2' : 2,
},
couponclickout: 
{
  'cctv:o': 111,
  'cctv:g': 112,
  'experiment2:alternative1' : 2011,
  'experiment2:alternative2' : 2012,
}

Redis: INCR en DECT


