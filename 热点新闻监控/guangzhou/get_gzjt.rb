#!/bin/usr/env ruby
# coding: gbk
#get_gzjt.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"#form1 table[2] tr").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end
    

doc = (doc/"#form1 table[2]")

(doc/"tr").each do |news|
    if (news/"a.agray").inner_html != ""
        href = "http://www.gzjt.gov.cn/gzjt/web/News/" + (news/"a.agray")[0].attributes['href'].strip
        title = "[guangzhou]" + Iconv.iconv("GBK//IGNORE", "UTF-8", (news/"td[1] span.agray").inner_html.to_s)[0].strip
        time = Iconv.iconv("GBK//IGNORE", "UTF-8", (news/"td[2] span.agray").inner_html.to_s)[0].strip
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
end

f_out.close
