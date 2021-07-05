#!/usr/local/bin/ruby -Ke

orignum = 0
File.foreach('/usr/home/minakaji/log/lognum.log') do |line|
  line.chomp!
  if (line =~ /([0-9+])/)
    orignum = line.to_i
  end
end
array = File.open('/circus/openlab/skk/log/registdic.log').readlines
num = array.length
File.open('/usr/home/minakaji/log/lognum.log', "w") do |file_handler|
  file_handler.print num
end
lost = orignum - num
if lost > 100
  subject = "Notice that #{lost} candidates in the registdic log have been lost"
  to = 'minakaji@osaka.email.ne.jp'
  system("date | mail -s \"#{subject}\" #{to}")
end

# end of checklog.rb
