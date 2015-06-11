# Path to hciconfig executable
EXEC = "/usr/sbin/hciconfig"

# Look for keywords in results
SSTR = ["UP", "DOWN", "RUNNING", "PSCAN", "ISCAN"]

# Interval
INTC = 10

# Check if running as root
raise "Must run as root" if not Process.uid == 0

puts "Daemon starting..."
begin
	while true
		# Fetch result
		result = `#{EXEC}`
		array = result.split("\t").map{|ln| ln.rstrip}
		#p array

		# Parse result
		hcimap = Hash.new()
		dev = nil
		for ln in array
			if match = ln.match(/^(hci\d+)/)
				dev = match.captures[0]
				if not hcimap.has_key? dev
					hcimap[dev] = nil
				else
					STDERR.puts "Warning: Duplicate HCI device identifiers"
				end
			else
				next if not dev
				if ln =~ /^[A-Z\s]+$/ and ln =~ /\b(UP|DOWN)\b/
					if not hcimap[dev]
						hcimap[dev] = Hash.new()
						for sstr in SSTR
							hcimap[dev][sstr] = ln =~ /\b#{sstr}\b/
						end
					else
						STDERR.puts "Warning: Duplicate HCI device state for #{dev}"
					end
				end
			end
		end
		#p hcimap
		dev = nil

		# Check state of each HCI device
		hcimap.each do |dev, states|
			if states.has_key? "DOWN" and states["DOWN"]
				puts "HCI device #{dev} is DOWN. Will bring it up."
				`hciconfig #{dev} up`
			elsif states.has_key? "UP" and states["UP"]
				if states.has_key? "PSCAN" and states["PSCAN"]
					nil
				else
					puts "HCI device #{dev} is UP without PSCAN. Will enable it."
					if states.has_key? "ISCAN" and states["ISCAN"]
						`hciconfig #{dev} piscan`
					else
						`hciconfig #{dev} pscan`
					end
				end
			end
		end

		# Sleep
		sleep INTC
	end
rescue SystemExit, Interrupt
	puts
ensure
	puts "Daemon terminated."
end

