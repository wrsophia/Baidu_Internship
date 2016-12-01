#!/bin/usr/env ruby
# coding: utf-8
#get_newsqq_society.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/'a.linkto').inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


(doc/'a.linkto').each do |news|
    href = news.attributes['href'].strip
    title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "GBK", news.inner_html.to_s)[0].strip
    time = " "
    now = Time.now
	    
	catch :doc_each do
        f_out.pos = 0
        while line = f_out.gets
            str = line.split
            if str[0] == href
                throw :doc_each
            end
        end
        f_out.puts("#{href}\t#{title}\t#{time}\t#{now}\n")
    end
end
        
f_out.close
