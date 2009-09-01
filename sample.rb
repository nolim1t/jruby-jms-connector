require 'jruby-jms.rb'

hashmap = Hash["m" => "Message", "a" => "alphabet"]

testqueue = JMS::QueueManager.new("TestQueue", "jms.properties")
if testqueue.Count(FALSE).to_i == 0 then
    testqueue.StringProduce("This is a test string", FALSE)
    testqueue.HashMapProduce(hashmap, FALSE) # Create hashmap
end
resp = testqueue.Consume
if resp.is_a?(String) then
    puts resp
else
    puts "The entry removed from the queue is not a string"
    if resp.respond_to? "getMapNames" then
        puts "Object is a Message Map"
        resp.getMapNames.each do |name|
            value = resp.getString(name)
            puts "#{name} = #{value}"
        end
    end
end
