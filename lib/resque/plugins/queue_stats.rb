require 'resque'

module Resque
  module Plugins
    module QueueStats

      def performed_count
        Resque.redis.get("stat:queue:#{@queue}:performed").to_i
      end

      def reset_performed_count
        Resque.redis.set("stat:queue:#{@queue}:performed",0)
      end

      def failed_count
        Resque.redis.get("stat:queue:#{@queue}:failed").to_i
      end

      def reset_failed_count
        Resque.redis.set("stat:queue:#{@queue}:failed",0)
      end

      def longest_job
        Resque.redis.get("stat:queue:#{@queue}:longest_job").to_f
      end

      def reset_longest_job
        Resque.redis.set("stat:queue:#{@queue}:longest_job",0.0)
      end

      def after_perform_queue_stats(*payload)
        Resque.redis.incr("stat:queue:#{@queue}:performed")
      end

      def around_perform_queue_stats(*payload)
        start = Time.now

        yield

        total_time = Time.now - start

        Resque.redis.multi do
          if longest_job.to_f < total_time.to_f
            Resque.redis.set("stat:queue:#{@queue}:longest_job",total_time)
          end
        end
      end

      def on_failure_queue_stats(e,*payload)
        Resque.redis.incr("stat:queue:#{@queue}:failed")
      end

    end
  end
end
