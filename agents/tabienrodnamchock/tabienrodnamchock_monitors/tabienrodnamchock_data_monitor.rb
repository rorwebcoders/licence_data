require "rubygems"
require 'logger' 


						Dir.mkdir("#{File.dirname(__FILE__)}/logs") unless File.directory?("#{File.dirname(__FILE__)}/logs")
						$logger = Logger.new("#{File.dirname(__FILE__)}/logs/tabienrodnamchock_data_monitor.log", 'weekly')
						#~ $logger.level = Logger::DEBUG
						$logger.formatter = Logger::Formatter.new

#~ while true do
pid_status_english = system("ps -aux | grep tabienrodnamchock_data_agent.rb | grep -vq grep")
				if pid_status_english
						$logger.info ("nothing to do....")
				else
						$logger.info ("Process started....")
						#~ system("nohup bundle exec /usr/bin/ruby ../tabienrodnamchock_data_agent.rb &")
						system("nohup bundle exec ruby /var/www/LegalSupportJobs/current/agents/tabienrodnamchock/tabienrodnamchock_data_agent.rb -e production &")
				end
#~ sleep 300
#~ end