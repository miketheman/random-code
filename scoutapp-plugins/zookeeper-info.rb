class ZookeeperMonitor < Scout::Plugin

  OPTIONS=<<-EOS
  port:
    name: Port
    notes: ZooKeeper listening port
    default: 2181
  EOS

  def build_report
    # Zero out all the variables we want to return
    lat_min, lat_avg, lat_max, received, sent, outstanding, node_count, mode = nil
    
    # Run the 4-letter command to grab the stats from the running service
    # Ref: http://zookeeper.apache.org/doc/r3.3.3/zookeeperAdmin.html#sc_zkCommands
    lines = shell("echo srvr | nc localhost #{option(:port)}")
    
    # This is what the output of the command looks like:
    
    # Zookeeper version: 3.3.3-cdh3u0--1, built on 03/26/2011 00:21 GMT
    # Latency min/avg/max: 0/0/0
    # Received: 68
    # Sent: 67
    # Outstanding: 0
    # Zxid: 0x400000002
    # Mode: follower
    # Node count: 4

    # Do this in pure ruby? Not worth the effort right now... http://www.ruby-doc.org/stdlib/libdoc/socket/rdoc/index.html
    # require 'socket'
    # 
    # client = TCPSocket.open("localhost", #{option(:port)} )    
    
    # Probably should do some sort of error handling in the event that the stat command returns nothing
    unless lines.empty?

      lines.each_line do |line|
        lat_min, lat_avg, lat_max = $1, $2, $3 if line =~ /^Latency min\/avg\/max:\s+(\d+)+\/+(\d+)+\/+(\d+)/
        received = $1 if line =~ /^Received:\s+(\d+)/
        sent = $1 if line =~ /^Sent:\s+(\d+)/
        outstanding = $1 if line =~ /^Outstanding:\s+(\d+)/
        node_count = $1 if line =~ /^Node count:\s+(\d+)/
        mode = $1 if line =~ /^Mode:\s+(\w+)/
      end
    
      # Build the output report
      report({:lat_min => lat_min, :lat_avg => lat_avg, :lat_max => lat_max, 
        :received => received, :sent => sent, :outstanding => outstanding, :node_count => node_count, :mode => mode }) 

    else
      error('Poopytime!','Apparently, the zookeeper service is not running on the specified port.')
    end

  end

  # Use this instead of backticks. It's a separate method so it can be stubbed for tests
  def shell(cmd)
    `#{cmd}`
  end
     
end