require 'helper'

class Job
  extend Resque::Plugins::QueueStats
  @queue = :test

  def self.perform(sleep_time = 0.1)
    sleep sleep_time
  end
end

class TestResqueQueueStats < Test::Unit::TestCase
  def setup
    @worker = Resque::Worker.new(:test)
  end

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::QueueStats)
    end
  end

  def test_performed_count

    Job.reset_performed_count

    assert_equal 0, Job.performed_count

    3.times { Resque.enqueue(Job) }
    3.times { @worker.work(0) }

    assert_equal 3, Job.performed_count

  end

  def test_longest_job

    Job.reset_longest_job

    assert_equal 0, Job.longest_job

    2.times { Resque.enqueue(Job) }
    Resque.enqueue(Job,0.5)

    3.times { @worker.work(0) }

    assert Job.longest_job > 0.4
  end
end
