# JRUBY JMS Utilities 
# This is a simple library which allows you to queue msgs, consume msgs from the queue, or count the message.

# Libraries required. (connector-api-1.5.jar may require downloading. the rest are with the openMQ package)
#export CLASSPATH="jms.jar:imq.jar:imqjmsra.jar:connector-api-1.5.jar"


require "java"
require 'imqlibs.jar'

include_class "javax.jms.Session"
include_class "com.sun.messaging.ConnectionFactory"
include_class "com.sun.messaging.Queue"

module JMS
	# Class name: QueueManager
	# Constructor parameters (queuename, properties_file)
	# Instance Methods:
	# StringProduce(msg) returns SUCCESS if successful
	# StringConsume() returns MSG=<MSG> if successful
	# Count() returns the length of the queue if successful
	class QueueManager
		def initialize(queuename='QUEUENAME', properties_file='jms.properties')
			begin
				myConnFactory = ConnectionFactory.new
                properties = java.util::Properties.new
                properties.load(java.io.FileInputStream.new(properties_file))
				myConnFactory.setProperty("imqBrokerHostName", properties.getProperty("com.bt.jms.servername"))
				myConnFactory.setProperty("imqBrokerHostPort", properties.getProperty("com.bt.jms.serverport"))
				myConnFactory.setProperty("imqDefaultUsername", properties.getProperty("com.bt.jms.username"))
				myConnFactory.setProperty("imqDefaultPassword", properties.getProperty("com.bt.jms.password"))
				
                @myConn = myConnFactory.createConnection
				@mySess = @myConn.createSession(false, Session::AUTO_ACKNOWLEDGE)
				@myQueue = Queue.new(queuename)
				@connectionSuccess = "TRUE"
			rescue
				@connectionSuccess = "FALSE"
			end
		end

        def HashMapProduce(hashmap, autoclose=TRUE)
            begin
                if @connectionSuccess == "TRUE" then
                    myMsgProducer = @mySess.createProducer(@myQueue)
                    myMapMsg = @mySess.createMapMessage()
                    # Go through each ruby hashmap entry and assign it to the java object
                    hashmap.each do |key, val|
                        myMapMsg.setString(key.to_s, val.to_s)
                    end
                    myMsgProducer.send(myMapMsg)
                    if autoclose == TRUE then
                        @mySess.close
                        @myConn.close
                    end
                    return "SUCCESS"
                else
                    return "ERR_NOCONNECTION"
                end
            rescue
                return "ERR_FAILURE"
            end
        end

		def StringProduce(msg, autoclose=TRUE)
			begin
				if @connectionSuccess == "TRUE"
					myMsgProducer = @mySess.createProducer(@myQueue)
					myTextMsg = @mySess.createTextMessage
					myTextMsg.setText(msg)
					myMsgProducer.send(myTextMsg)
			        if autoclose == TRUE then
					    @mySess.close
					    @myConn.close
                    end
					return "SUCCESS"
				else
					return "ERR_NOCONNECTION" # There is no connection
				end
			rescue
				return "ERR_FAILURE" # Something else broke
			end
		end
		
        def Consume(autoclose=TRUE)
            myConsumer = @mySess.createConsumer(@myQueue)
            @myConn.start()
            receiverobj = myConsumer.receive(1000)
            if receiverobj.respond_to? 'text'
                msg=receiverobj.text
            else
                msg = receiverobj
            end
            if autoclose == TRUE then
                @mySess.close
                @myConn.close
            end
            return msg
        end

		def Count(autoclose=TRUE)
			begin
				browser = @mySess.createBrowser(@myQueue)
				benum = browser.getEnumeration()
				queue = 0
				while benum.hasMoreElements() do
					queue = queue + 1
					benum.nextElement()
				end
                if autoclose == TRUE then
				    @mySess.close
				    @myConn.close
                end
				return "#{queue}"
			rescue
				return "ERR_FAILURE"
			end		
		end
    
    end
end
