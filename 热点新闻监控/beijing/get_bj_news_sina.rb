#!/bin/usr/env ruby
# coding: gbk
#get_bj_news_sina.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"ul.listS3>li").to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end
    

(doc/"ul.listS3>li").each do |news|
    href = (news/"a")[0].attributes['href'].strip
    title = "[beijing]" + Iconv.iconv("GBK//IGNORE", "GBK", (news/"a").inner_html.to_s)[0].strip
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
