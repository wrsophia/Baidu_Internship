#!/bin/usr/env ruby
# coding: gbk
#get_sh_122.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"li.top a").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end
 
  
(doc/"li.top").each do |news|
    href = "http://sh.122.gov.cn" + news.search("/a")[0].attributes['href'].strip
    title = "[shanghai]" + Iconv.iconv("GBK//IGNORE", "UTF-8", news.search("/a").inner_html.to_s)[0].strip
    title_t = /(.+)?(?=<i class=)/.match(title)
    if title_t != nil
        title = title_t[0]
    end
    time = Iconv.iconv("GBK//IGNORE", "UTF-8", news.search("/p/span").inner_html.to_s[-10,10])[0].strip
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
