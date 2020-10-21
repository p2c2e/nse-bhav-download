# nse-bhav-download

Downloads the Bhavcopy CSV files from NSE site
Uses little bit of smarter to avoid redownloads and 404, holidays etc.

* How to use?

ruby bhav_copy_download.rb
Usage: ruby getbhavcopy.rb <year> <month> <day> [no.of.days] [pause.secs]

For Example:
ruby bhav_copy_download.rb 2020 10 1 20 2

which means, starting from 2020-Oct-1 download 20 calendar days of data and pause 2 seconds between downloads to avoid spamming...


