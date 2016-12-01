#!/bin/usr/env ruby
# coding: gbk
#get_view163.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if doc.search('//*[@id="theotherside_new_wrap"]/div[2]/div[3]/div[2]/div').inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end


doc.search('//*[@id="theotherside_new_wrap"]/div[2]/div[3]/div[2]/div').each do |e|
    href = e.search('/h2/a')[0].attributes['href'].strip
    title = "[quanguo]" + Iconv.iconv("GBK//IGNORE", "GBK", e.search('/h2/a').inner_html.to_s)[0].strip
    time = Iconv.iconv("GBK//IGNORE", "GBK", e.search('/div[1]/span[3]').inner_html.to_s)[0].strip
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
