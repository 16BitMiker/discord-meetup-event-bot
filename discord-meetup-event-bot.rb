#!/usr/bin/env ruby
#          _ _                               _ _         
#    /\/\ (_) | _____ _ __    /\/\   ___  __| (_) __ _   
#   /    \| | |/ / _ \ '__|  /    \ / _ \/ _` | |/ _` |  
#  / /\/\ \ |   <  __/ |    / /\/\ \  __/ (_| | | (_| |  
#  \/    \/_|_|\_\___|_|    \/    \/\___|\__,_|_|\__,_|  
#   
# Discord Meetup Event Bot v0.1
# by https://miker.media

require 'colorize'
require 'strscan'
require 'watir'
require 'htmlentities'

class Discord_Meetup_Updater

	def initialize(meetup,discord)
	
		@ff = Watir::Browser.new :firefox, headless: true
		
		@events = []
		@meetup = meetup.sub(%r~/$~) { %q|| }
		@coder = HTMLEntities.new
		
		@s    = ''
		@html = ''
		
		@q  = %Q|\u0027|
		@qq = %Q|\u0022|
		
		@emojii = %q|📣 🌟 ✨ ⚡️ 🌀|
		@emojiis = []
		
		@curl = <<-"CURL".gsub(%r~^\s+|^$~,%q||)
			curl -sS -i \\
			-H "Accept: application/json" \\
			-H "Content-Type:application/json" \\
			-X POST --data \\
			#{@qq}{\\#{@qq}content\\#{@qq}: \\#{@qq}MESSAGE\\#{@qq}}#{@qq} \\
			#{@q}#{discord}#{@q} 
		CURL
		
	end
	
	def run()
	
		loop do
			if @events.length == 0 then
				self.get_html
				self.meetup_parse 
			end
			
			if @emojiis.length == 0 then
				@emojiis = @emojii.split(%r~\s~)
			end
			
			emojii = (@emojiis.shuffle.pop) + %q| |
			
			event = @events.shuffle.pop
			
			time = Time.now.to_i
			future = (event[:epoch].to_s.sub(%r~^(\d{#{time.to_s.length}}).*~) { $1 }).to_i;

			next if ((future - time) < 86400)
			
			message = <<-"MSG".gsub(%r~^\s+|^$|\n~,%q||)
				#{emojii * 10}\\n
				*PSSSSSSSSSSSSSSSSSSSSSSST*\\n
				Check Out This Upcoming Event:\\n
				**Title:** #{event[:title]}\\n
				**Date:** #{event[:date]}\\n
				**Time:** #{event[:time]}\\n
				RSVP @ <#{event[:url]}> 👀\\n
				#{emojii * 10}\\n
			MSG
			
			message.gsub!(%r~[#{@qq}]~) { %q|| }
			
			%x|#{@curl.sub(%r~MESSAGE~,message)}|
			
			if $? == 0
				puts %Q|> Event: | + %Q|#{@q}#{event[:title]}#{@q}|.yellow + %q| >> | + %q|promoted successfully!|.green 
			else
				puts %Q|Can't connect to discord, quitting.|.red
				exit 69
			end
			
			self.sleepy_time(86400, 60)
		end
		
	end
	
	private
	
	def wait_for(method,hash)
		Watir::Wait.until(timeout: 60) { @ff.send(method, hash).visible? }
	end
	
	def sleepy_time(static, random)
		zzz = rand(random) + static
		puts %Q|> Sleeping for | + zzz.to_s.blue  + %q| seconds.|
		sleep zzz
	end
	
	def get_html
		@ff.goto(@meetup) 
		
		@html = @ff.html
		@html.gsub!(%r~\n~) { %q| | }
	end
	
	def meetup_parse
	
		n = 0
		
		@s = StringScanner.new(@html)
		
		until @s.eos? || @s.check_until(%r~id="eventCard-\d+~).nil?
		
			@s.skip_until(%r~id="eventCard-\d+~)
			@events[n] = {}
			
			# href
			@s.skip_until(%r~<a href="~)
			@events[n][:url] = %Q|https://meetup.com/#{@s.scan_until(%r~[^"]+~)}|
			
			# title
			@s.skip_until(%r~visibility--a11yHide">~)
			@events[n][:title] = @coder.decode(@s.scan_until(%r~(?=<)~))
			
			# epoch
			@s.skip_until(%r~datetime="~)
			@events[n][:epoch] = @s.scan_until(%r~(?=")~)
			
			# date
			@s.skip_until(%r~eventTimeDisplay-startDate"><span>~)
			@events[n][:date] = @s.scan_until(%r~(?=<)~)
			
			# time
			@s.skip_until(%r~eventTimeDisplay-startDate"><span>~)
			@events[n][:time] = @s.scan_until(%r~(?=<)~)
			
			n += 1
			
		end
		
	end
	
end

discord = 'Discord Webhook'
meetup  = 'https://www.meetup.com/GROUPNAME/events/'

discord = Discord_Meetup_Updater.new(meetup,discord)
discord.run()

__END__
