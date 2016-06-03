require 'yaml'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
def read_file(file_name,num)
	json = File.read(file_name)
	obj = JSON.parse(json)
	if num == 1 
		puts "Thread 1 #{obj[1]["id"]}"
	elsif num == 2 
		puts "Thread 2 #{obj["current_user_url"]}"
	elsif num == 3
		puts "Thread 3 #{obj["timeline_url"]}"	
	end
end
def get_http(type,key,url_data,num)

	res ="#{url_data[type][key]}"
	aFile = File.new("Thread#{num}.json", "w+")
	if aFile
		url = URI.parse(res)
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true if url.scheme == 'https'
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
		http.start {
	       		http.request_get(url.path) {|res|
   			aFile.syswrite(res.body)
	  			}
		
			}	
	read_file("Thread#{num}.json",num)
	else
  		puts "Unable to open file!"
	end 
end
data= YAML.load(File.open('a.yml'))
num = data.length
while num > 0 do
		begin
 			num = num - 1 
			t1 = Thread.new{get_http("test#{num + 1}","adapter",data,num + 1)}
		rescue Exception => e
   			 puts "Exception occoured in working thread, stack trace:"
                 	e.backtrace.each { |trace| puts "  -- #{trace}" }
                 	puts "looping next ..."
                 	next
		end
		t1.join			
end
