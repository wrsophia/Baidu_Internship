#!/bin/usr/env ruby
# coding : gbk
#link_html_ruby.rb
#################################

require 'iconv'
require 'hpricot'
require 'readline'
require 'fileutils'

file = File.open("#{ARGV[0]}", "a+")
file = File.open("#{ARGV[0]}", "a+")

file.puts("abcd\n")

