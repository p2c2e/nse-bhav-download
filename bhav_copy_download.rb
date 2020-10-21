#
# To get historical quotes from NSE
#

# "http://archives.nseindia.com/content/historical/EQUITIES" + td.strftime("/%Y/%b/").upcase! + "cm" + td.strftime("%d%b%Y").upcase! + "bhav.csv.zip"
# Sample:
# https://archives.nseindia.com/content/historical/EQUITIES/2020/OCT/cm01OCT2020bhav.csv.zip
#
#

# Let us assume we pass in a year month date 
# optionally a period (number of days from then)
# Files are cached on /tmp similar to Finance Quotes
#
# The "number days" includes any holidays. Sat / Sun are ignored
#

require 'zip'
require 'date'
require 'open-uri'

# 
# EDIT THESE VARIABLES BEFORE YOU RUN 
# 

target_prefix = "/tmp/bhavcopy.csv"
# The file and folder is used for each daily download (overwritten)
zipfile = "/tmp/bhavfile.zip"
zipfolder = "/tmp/bhavfile_tmp"
#target_prefix = "/home/r.sudharsan/bhav/bhavcopy.csv"

#
# YOU DON"T NEED TO EDIT BEYOND THIS
#

source_prefix = "https://archives.nseindia.com/content/historical/EQUITIES"

counter = 1 # No of days of files
delay = 1 # Seconds to sleep between requests 
if ARGV.length == 0 then
  # date = Date.today
  puts "Usage: ruby getbhavcopy.rb <year> <month> <day> [no.of.days] [pause.secs]"
  exit 0
else 
  if ARGV.length >= 3 then
  date = Date.new( ARGV[0].to_i , ARGV[1].to_i , ARGV[2].to_i )
  end
  if ARGV.length >= 4 then
  counter = ARGV[3].to_i
  end 
  if ARGV.length == 5 then
  delay = ARGV[4].to_i
  end 
end

# Taken from location on internet

def extract_zip(file, destination)
  FileUtils.mkdir_p(destination)

  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(destination, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end
end

shortit = false
currentdate = Date.today

while counter > 0 do
  begin
    if currentdate - date < 0 then
       puts "Future date ( "+date.strftime("%Y-%b-%d")+" ) - Today is ( "+currentdate.strftime("%Y-%b-%d")+" ) - exiting"
       break
    end
    # Skip Sunday and Saturday (NSE holidays)
    if true then # date.wday != 0 and date.wday != 6 then 
      source_url = source_prefix + date.strftime("/%Y/%b/").upcase! + "cm" + date.strftime("%d%b%Y").upcase! + "bhav.csv.zip"
      source_file = "cm" + date.strftime("%d%b%Y").upcase! + "bhav.csv"

      puts source_url

      #target_file = target_prefix + "." + date.strftime("%d%b%Y").upcase!
      target_file = target_prefix + "." + date.strftime("%Y%m%d")

      if File.exists?("#{target_file}.404") then
                puts "File seems to be 404 status" 
      else 
         if ! File.exists?(target_file) then
              File.open(zipfile, "w") do |f|
                  f << open(source_url, :redirect=>false, :read_timeout=>6).read
              end
              extract_zip(zipfile, zipfolder)
              File.rename(zipfolder + "/" + source_file, target_file)
          else
              puts "File seems to be present " + target_file
              shortit = true
          end
      end
    end
  rescue Exception => e
    puts "Exception : " + e.message
    if File.exists?(zipfile) then
      File.delete(zipfile); # Most likely a zero size file 
    end
    if e.message.include?("404") || e.message.include?("302") then
        File.open("#{target_file}.404", "w")
        puts "Created a 404 file"
    end
  end

  counter = counter - 1
  date = date.next
    if ! shortit then
        sleep(delay) # secs - throttle down to avoid load ...
        shortit = false
    end
end


