# JRUBY JMS Utilities 
# This is a simple library which allows you to queue msgs, consume msgs from the queue, or count the message.

# Libraries required. (connector-api-1.5.jar may require downloading. the rest are with the openMQ package)
#export CLASSPATH="jms.jar:imq.jar:imqjmsra.jar:connector-api-1.5.jar"


require "java"

include_class "javax.jms.Session"
include_class "com.sun.messaging.ConnectionFactory"
include_class "com.sun.messaging.Queue"

module JMS
	# Class name: QueueManager
	# Constructor parameters (queuename, server, port, username, password)
	# Instance Methods:
	# Produce(msg) returns SUCCESS if successful
	# Consume() returns MSG=<MSG> if successful
	# Count() returns the length of the queue if successful
	class QueueManager
		def initialize(queuename='QUEUENAME', server='ADDR', port='7676', uid='admin', pwd='admin')
			begin
				myConnFactory = ConnectionFactory.new
				myConnFactory.setProperty("imqBrokerHostName", server)
				myConnFactory.setProperty("imqBrokerHostPort", port)
				myConnFactory.setProperty("imqDefaultUsername", uid)
				myConnFactory.setProperty("imqDefaultPassword", pwd)
				@myConn = myConnFactory.createConnection
				@mySess = @myConn.createSession(false, Session::AUTO_ACKNOWLEDGE)
				@myQueue = Queue.new(queuename)
				@connectionSuccess = "TRUE"
			rescue
				@connectionSuccess = "FALSE"
			end
		end
		
		def Produce(msg)
			begin
				if @connectionSuccess == "TRUE"
					myMsgProducer = @mySess.createProducer(@myQueue)
					myTextMsg = @mySess.createTextMessage
					myTextMsg.setText(msg)
					myMsgProducer.send(myTextMsg)
			
					@mySess.close
					@myConn.close
					return "SUCCESS"
				else
					return "ERR_NOCONNECTION" # There is no connection
				end
			rescue
				return "ERR_FAILURE" # Something else broke
			end
		end
		
		def Consume
			begin
				myConsumer = @mySess.createConsumer(@myQueue)
				@myConn.start()
				receiverobj = myConsumer.receive(1000)
				msg = ""
				receiverobj.methods.each { |rm| if rm == "text" then; msg=receiverobj.text; end }
				@mySess.close
				@myConn.close			
				if (msg.length > 1) then
					return "#{msg}"
				else
					return "ERR_NOMESSAGES"
				end
			rescue
				return "ERR_FAILURE"
			end
		end
		
		def Count
			begin
				browser = @mySess.createBrowser(@myQueue)
				benum = browser.getEnumeration()
				queue = 0
				while benum.hasMoreElements() do
					queue = queue + 1
					benum.nextElement()
				end
				@mySess.close
				@myConn.close			
				return "#{queue}"
			rescue
				return "ERR_FAILURE"
			end		
		end
	end
end
