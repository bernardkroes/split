module Split
  class Counter
    attr_accessor :name

    def self.hash_name_for_name(in_name)
      "co:#{in_name}"
    end

    def self.keyname_for_experiment_and_alternative(experiment, alternative)
      [experiment.gsub(":", ""), alternative.gsub(":", "")].join(':')
    end

    def self.inc(name, experiment, alternative)
      Split.redis.hincrby(Split::Counter.hash_name_for_name(name), Split::Counter.keyname_for_experiment_and_alternative(experiment, alternative), 1)
    end

    def self.current_value(name, experiment, alternative)
      Split.redis.hget(Split::Counter.hash_name_for_name(name), Split::Counter.keyname_for_experiment_and_alternative(experiment, alternative))
    end

    def self.exists?(name)
      Split.redis.exists(Split::Counter.hash_name_for_name(name))
    end

    def self.delete(name)
      Split.redis.del(Split::Counter.hash_name_for_name(name))
    end

    def self.reset(name, experiment, alternative)
      Split.redis.hdel(Split::Counter.hash_name_for_name(name), Split::Counter.keyname_for_experiment_and_alternative(experiment, alternative))
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


