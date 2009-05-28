# JRUBY Queue Management 
# This creates an entry onto a JMS Queue

require "java"

include_class "javax.jms.Session"
include_class "com.sun.messaging.ConnectionFactory"
include_class "com.sun.messaging.Queue"

module JMS
	class Producer
		def initialize(queuename='JMSQUEUENAME', server='jmshost', port='7676', uid='admin', pwd='admin')
			myConnFactory = ConnectionFactory.new
			myConnFactory.setProperty("imqBrokerHostName", server)
			myConnFactory.setProperty("imqBrokerHostPort", port)
			myConnFactory.setProperty("imqDefaultUsername", uid)
			myConnFactory.setProperty("imqDefaultPassword", pwd)

			@myConn = myConnFactory.createConnection()
			@mySess = @myConn.createSession(false, Session::AUTO_ACKNOWLEDGE)
			@myQueue = Queue.new(queuename)
		end
		
		def Produce(msg)
			myMsgProducer = @mySess.createProducer(@myQueue)
			myTextMsg = @mySess.createTextMessage()
			myTextMsg.setText(msg)
			myMsgProducer.send(myTextMsg)
			
			@mySess.close()
			@myConn.close()			
		end
	end
end
