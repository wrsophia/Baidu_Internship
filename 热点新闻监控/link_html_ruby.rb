#!/bin/usr/env ruby
# coding : gbk
#link_html_ruby.rb
#################################

require 'iconv'
require 'hpricot'
require 'readline'
require 'fileutils'

t = Time.new.strftime("%Y%m%d%H%M")
system("touch ./output/#{t}")

suffix="html_ruby.map"
dir = ["quanguo", "beijing", "shanghai", "shenzhen", "guangzhou"]
for name in dir
    Dir.foreach("./#{name}/out/") do |out|
        if out !="." and out !=".."
            system("rm -f ./#{name}/out/#{out}")
        end
    end
    mapfile = "./#{name}/#{suffix}"
    if File.exist?("#{mapfile}")
        file = File.open("#{mapfile}", "r")
        while line = file.gets
            line = line.chomp
            command = "ruby " + line
            res = system("#{command}")
            if (!res)
                print "false #{command}\n"
            end
        end
    else
        print "#{mapfile} not exist!"
    end
    Dir.foreach("./#{name}/out/") do |out|
        if out !="." and out !=".."
            system("cat ./#{name}/out/#{out} >> ./output/#{t}")
        end
    end
end
