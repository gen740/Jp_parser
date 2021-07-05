#!/usr/local/bin/ruby -Kj
#
# Copyright (C) 2002, 2003, 2004 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>

# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
# Maintainer: SKK Development Team <skk@ring.gr.jp>
# Version: $Id: commit_and_mail.rb,v 1.14 2005/10/23 17:11:51 skk-cvs Exp $
# Keywords: japanese, dictionary, web maintenance
# Created: Oct. 13, 2002
# Last Modified: $Date: 2005/10/23 17:11:51 $

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program, see the file COPYING.  If not, write to the
# Free Software Foundation Inc., 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.

## Commentary:

Cam_Debug = false # true
#require 'kconv'
require 'csv'
require 'mail'
require 'nkf'
require 'changelog'
require 'logdic'

L_Header = <<EOF
;; -*- mode: fundamental; coding: euc-jp -*-
;; Large size dictionary for SKK system
;; Copyright (C) 1988-1995, 1997, 1999-2005
;;
;; Masahiko Sato <masahiko@kuis.kyoto-u.ac.jp>
;; Hironobu Takahashi <takahasi@tiny.or.jp>,
;; Masahiro Doteguchi, Miki Inooka,
;; Yukiyoshi Kameyama <kameyama@kuis.kyoto-u.ac.jp>,
;; Akihiko Sasaki, Dai Ando, Junichi Okukawa,
;; Katsushi Sato and Nobuhiro Yamagishi
;; NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
;; MITA Yuusuke <clefs@mail.goo.ne.jp>
;; SKK Development Team <skk@ring.gr.jp>
;;
;; Maintainer: SKK Development Team <skk@ring.gr.jp>
;; Version: $Id: commit_and_mail.rb,v 1.14 2005/10/23 17:11:51 skk-cvs Exp $
;; Keywords: japanese
;; Last Modified: $Date: 2005/10/23 17:11:51 $
;;
;; This dictionary is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This dictionary is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Daredevil SKK, see the file COPYING.  If not, write to
;; the Free Software Foundation Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;; ACKNOWLEDGEMENT
;;
;; この辞書は、SKK 原作者の佐藤雅彦先生が、第 1 版作成のために東北大学
;; 電気通信研究所佐藤研究室 (当時) の学生さん達とともに scratch から作
;; 成されたのをその起源とし、その後、無数のユーザからのユーザ辞書の提
;; 供やフォームによる追加・校閲によって今尚日々メンテナンスされている日
;; 本で最大規模の、GPL による copy free の辞書です。
;;
;; この辞書の作成にご尽力頂いた全ての方に感謝すると共に、これをお読み
;; のあなたのご協力を是非ともお待ちしております。
;;
;;   http://openlab.ring.gr.jp/skk/registdic.cgi
;;
;; にアクセスし、フォームに是非あなたの新語・誤登録指摘・コメントを書
;; いて下さい。
;;
;; また、実際に辞書の編集をしてみたいという方は、
;;
;;   http://openlab.ring.gr.jp/skk/cvs-ja.html#account
;;
;; をご覧の上、cvs account の発行申し込みをして下さい。
;;
;; 辞書の編集方針は skk/dic/READMEs/committers.txt をご参照下さい。
;; そこに記載のない事項、またその変更については、その都度 SKK Openlab
;; ML で話し合いで決められます。
;;
EOF

Jinmei_Header = <<EOF
;; 人名辞書 for SKK system
;; Copyright (C) 1993 Wnn Consortium
;; Copyright (C) 2004 Akie Kaidoh <kaidoh@ma.ctk.ne.jp>
;; Copyright (C) 2002-2005 SKK Development Team <skk@ring.gr.jp>
;;
;; Author: OMRON SOFTWARE Co., Ltd. <freewnn@rd.kyoto.omronsoft.co.jp>
;; Maintainer: SKK Development Team <skk@ring.gr.jp>
;; Version: $Id: commit_and_mail.rb,v 1.14 2005/10/23 17:11:51 skk-cvs Exp $
;; Keywords: japanese
;; Last Modified: $Date: 2005/10/23 17:11:51 $
;;
;; This dictionary is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This dictionary is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; 本辞書は、skk/tools/convert2skk/wnn2skk.awk を利用し「人名辞書
;; (gerodic) 1.00」を SKK 辞書形式に変換したものをベースに加除した
;; ものです。
;;
;;   % gawk -f wnn2skk.awk gerodic/g-jinmei.u > temp
;;   % skkdic-expr temp | skkdic-sort > SKK-JISYO.jinmei
;;
;; Wnn の品詞データ、コメントは SKK annotation として辞書内に含め
;; ています。annotation が不要な方は skk/dic/unannotation.awk を利
;; 用して削除して下さい。
;;
;; (追記)
;; 音訳用の「人名録」に採録されている、新聞に出現した人名約 25,000
;; を、姓と名に分解して抽出した 11,498 candidates を増補しました。
;;
;;   http://www.ctk.ne.jp/~kaidoh/
;;
;; 利用を快諾して下さった、「人名録」運営者の海道昭恵様のご厚意に
;; 感謝します。
;;
EOF

Tmpdir = '/usr/home/minakaji/tmp/'
Codir = '/usr/home/minakaji/skk/dic/'
Tmp0 = Tmpdir + 'SKK-JISYO.tmp.0'
Tmp1 = Tmpdir + 'SKK-JISYO.tmp.1'
ChangeLog_Tmp = Tmpdir + 'ChangeLog.tmp'
ChangeLog_Orig = Codir + 'ChangeLog'

def make_new_JISYO(dictionary_file, logdic, header = '')
  num = 0
  File.open(dictionary_file, 'a') do |file_handler|
    logdic.each do |con0, con1|
      num = num + con1.length
      file_handler.print con0, " /", con1.join("/"), "/\n"
    end
  end
  command = '/usr/home/minakaji/bin/skkdic-expr2 ' + dictionary_file + ' >' + Tmp0
  if !(ret = system(command)) # filtered by skkdic-expr2
    return false
  end
  File.open(Tmp1, 'w') do |tmp1|
    # add header
    tmp1.print header
    File.open(Tmp0, 'r') do |tmp0|
      tmp1.print tmp0.readlines
    end
  end
  if File.exist?(Tmp0)
    File.unlink(Tmp0)
  end
  if File.exist?(Tmp1)
    File.rename(Tmp1, dictionary_file)
  end
  num
end

def make_new_ChangeLog(changelog)
  File.open(ChangeLog_Orig) do |orig|
    File.open(ChangeLog_Tmp, 'w') do |new|
      new.print changelog, "\n"
      new.print orig.readlines
    end
  end
  if File.exist?(ChangeLog_Tmp)
    File.rename(ChangeLog_Tmp, ChangeLog_Orig)
  end
end

def main(dictionary_file, header)
  basename = File.basename(dictionary_file)
  if basename == 'SKK-JISYO.jinmei'
    logdic = Logdic.new.make_jinmei()
  elsif basename == 'SKK-JISYO.L'
    logdic = Logdic.new.make(false, true, false)
  else
    raise 'Error: Unknown dictionary!'
  end
  if File.exist?(ChangeLog_Orig)
    File.unlink(ChangeLog_Orig)
  end
  if File.exist?(dictionary_file)
    File.unlink(dictionary_file)
  end
  command = "cd /usr/home/minakaji ; cvs checkout skk/dic/#{basename} skk/dic/ChangeLog"
  if !((logdic.size > 0) && system(command))
    return false
  end
  changelog = ChangeLog.new
  changelog_txt = changelog.make(dictionary_file, logdic)
  make_new_ChangeLog(changelog_txt)
  # remake changelog to fold lines...
  changelog_txt = changelog.make(dictionary_file, logdic, true, true)

  num = make_new_JISYO(dictionary_file, logdic, header)
  command = 'cd /usr/home/minakaji ; cvs commit -m "See ChangeLog." skk/dic/ChangeLog ' + "skk/dic/#{basename}"

  if !Cam_Debug
    if !system(command)
      return false
    end
  end
  print command, "\n" if Cam_Debug
  skk_jisyo = ''
  logdic.sort.each do |con0, con1|
    temp = con0 + " /" + con1.join("/") + "/\n"
    skk_jisyo << NKF.nkf('-jf310', temp)
  end
  mail = Mail.new
  subj = "Request for comment on new commitment of #{basename}"
  from = 'skk@ring.gr.jp'
  sender = 'minakaji@ring.gr.jp'
  if Cam_Debug
    to = 'minakaji@osaka.email.ne.jp'
  else
    to = 'skk@ring.gr.jp'
  end
  if basename == 'SKK-JISYO.jinmei'
    mesg = <<-EOF
  http://openlab.ring.gr.jp/skk/registdic.cgi に登録された辞書追加希望エント
リのうち、人名関係として登録された語 #{num} 語を機械的に追加し commit いたしま
した。
EOF
  elsif basename == 'SKK-JISYO.L'
    mesg = <<-EOF
  これは skk@ring.gr.jp に週一回自動送付されるメッセージです。

  http://openlab.ring.gr.jp/skk/registdic.cgi に登録された辞書追加希望エント
リのうち、goo 辞書に掲載されている語 #{num} 語を機械的に追加し commit いたしま
した。
EOF
  end
  mesg = mesg + <<-EOF
これらの追加について、ご検証いただきますようリクエストいたします。

同じ見出し語が既に辞書にあった場合は、新規の候補は、機械的に最後尾に追加され
ています。他の語との頻度などを考慮して、候補の順番を変更することが期待されま
す。

また、http://openlab.ring.gr.jp/skk/registdic.cgi に「用例等」として登録され
た内容は、機械的に annotation として追加してあります。適切に変更するなり、不
要であれば削除するなりすることが期待されます (なお、L 辞書には積極的に
annotation を付けることが推奨されています)。

コメントを skk@ring.gr.jp までお寄せいただき、または手作業によって編集 &
commit いただきますよう宜しくお願いいたします。
EOF
  mesg = NKF.nkf('-j', mesg)
  mail.send(subj, from, sender, to, mesg,
	    "ChangeLog", changelog_txt, "SKK-JISYO.tmp", skk_jisyo)
end

main(Codir + 'SKK-JISYO.L', L_Header)
main(Codir + 'SKK-JISYO.jinmei', Jinmei_Header)
# end of commit_and_mail.rb
