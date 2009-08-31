require 'jruby-jms.rb'

testqueue = JMS::QueueManager.new("TestQueue", "jms.properties")
puts testqueue.Count
