"""
skkdict.py --- pySKK native dictionary class
Copyright (C) 2000 Mikio Nakajima <minakaji@osaka.email.ne.jp>

Author: Mikio Nakajima <minakaji@osaka.email.ne.jp>
Maintainer: Mikio Nakajima <minakaji@osaka.email.ne.jp>
Version: $Id: skkdict.py,v 1.1 2000/09/04 11:33:49 minakaji Exp $
Keywords: japanese
Created:
Last Modified: $Date: 2000/09/04 11:33:49 $

pySKK is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either versions 2, or (at your option) any later
version.

pySKK is distributed in the hope that it will be useful but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for more details.

You should have received a copy of the GNU General Public License
along with pySKK, see the file COPYING.  If not, write to the Free
Software Foundation Inc., 59 Temple Place - Suite 330, Boston,
MA 02111-1307, USA.

Commentary:
"""
### Code:
import os, sys
from string import find, joinfields, lower, splitfields, strip
from tempfile import gettempdir, gettempprefix
from posixpath import basename, expanduser, getsize

#class DirectAccessDictionary:
class SkkDictionary:
   def setup(self, filename):
      self.filename = filename 
      self.assoc = {}
      self.okurigana = ''

      # XXX where to be defined?
      self.use_numeric_conversion = 0
      # XXX other search options?
      
      # XXX where to be defined?
      # XXX other internal variables which represent status of the current conversion?
      self.num_list = 0

      input = open(expanduser(filename), 'r')
      lines = input.readlines()
      for l in lines:
         if l[:-1] == ';; okuri-ari entries.':
            okurigana = 1
         elif l[:-1] == ';; okuri-nasi entries.':
            okurigana = 0
         # non comment line --- entry to be processed.
         elif l[:2] != ';;':
            n = find(l, ' ', 0)
            (key, can) = l[:n], l[n + 2:-2]
            can = splitfields(can, '/')
            # okuri-nasi entries.
            if okurigana == 0:
               self.assoc[key] = can
            # okuri-ari entries (without brackets).
            elif not ']' in can:
               # empty dictionary in index 0 may be used when user change
               # option to use okurigana strictly search after invoking pySKK.
               self.assoc[key] = [{}] + can
            # okuri-ari entries (with brackets).
            else:
               l0 = [] # list for non-`okuri strictly' environment.
               n = 0
               max = len(can) - 1
               nestdict = {}
               while max >= n:
                  if can[n] == ']':
                     sys.stderr.write('close bracket comes before open one!\n' )
                  # makeing dict up for `okuri strictly' environment.
                  elif can[n][0] == '[':
                     l1 = [] # list for `okuri strictly' environment.
                     nestkey = can[n][1:]
                     n = n + 1
                     # process CAN until next close bracket comes.
                     while (max >= n and can[n] != ']'):
                        l1.append(can[n])
                        n = n + 1
                     if can[n] == ']':
                        nestdict[nestkey] = l1
                  # nothing to do with blacket parens.
                  else:
                     l0.append(can[n])
                  n = n + 1
                  # [{'¤Ã¤Æ' : ['Çã', '¾¡'], '¤Ã¤¿' : ['Çã', '¾¡']},'Çã', '¾¡']
                  #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^
                  #       n e s t d i c t (nestkey is okurigana)   ,    L0
                  self.assoc[key] = [nestdict] + l0
      input.close

   def search(self, key, okurigana):
      # keep them for dictionary updates.
      self.okurigana = okurigana
      self.henkan_key = key
      # XXX 
      if not self.okurigana and self.use_numeric_conversion:
         import skknum
         self.henkan_key = skknum.make_henkan_key(self.henkan_key)
      list = self.assoc[self.henkan_key]
      if not self.okurigana:
         if not self.num_list:
            return list
         else:
            list1 =[]
            for e in list:
               # XXX
               list1.append(skknum.convert(e, self.num_list))
            return list1
      # lines below are for okuri-ari.
      elif self.okuri_strictly:
         return list[0][okurigana]
      elif self.okuri_precedence:
         append = []
         for other in list[1]:
            if not other in list[0][okurigana]:
               append.append(other)
         return list[0][okurigana] + append
      # anything else?
      else:
         return list[1]
      
   # XXX for debugging
   def get_candidates(self, key):
      for as in self.assoc[key]:
         print as

class PrivateDictionary(SkkDictionary):
   def setup(self, filename):
      self.filename = filename
      self.assoc = {}
      self.okurigana = ''

      # XXX where to be defined?
      self.use_numeric_conversion = 0
      # XXX other search options?
      
      # XXX where to be defined?
      # XXX other internal variables which represent status of the current conversion?
      self.num_list = 0

      # keyword list
      self.okuri_ari = []
      self.okuri_nasi = []
      input = open(expanduser(filename), 'r')
      lines = input.readlines()
      for l in lines:
         if l[:-1] == ';; okuri-ari entries.':
            okurigana = 1
         elif l[:-1] == ';; okuri-nasi entries.':
            okurigana = 0
         # non comment line --- entry to be processed.
         elif l[:2] != ';;':
            n = find(l, ' ', 0)
            (key, can) = l[:n], l[n + 2:-2]
            if okurigana == 1:
               self.okuri_ari.append(key)
            else:
               self.okuri_nasi.append(key)
            can = splitfields(can, '/')
            # XXX same keys may exist in okuri_ari and okuri_nasi...
            if self.assoc.has_key(key):
               # just warn, continue anyway...
               sys.stderr.write('duplicated key %s exists in %s\n' % key, self.filename)
            # okuri-nasi entries.
            if okurigana == 0:
               self.assoc[key] = can
            # okuri-ari entries (without brackets).
            elif not ']' in can:
               # empty dictionary in index 0 may be used when user change
               # the option to use okurigana strictly search after invoking pySKK.
               self.assoc[key] = [{}] + can
            # okuri-ari entries (with brackets).
            else:
               # list for non-`okuri strictly' environment.
               l0 = []
               n = 0
               max = len(can) - 1
               nestdict = {}
               while max >= n:
                  if can[n] == ']':
                     sys.stderr.write('close bracket comes before open one!\n')
                  # makeing dict up for `okuri strictly' environment.
                  elif can[n][0] == '[':
                     # list for `okuri strictly' environment.
                     l1 = []
                     nestkey = can[n][1:]
                     n = n + 1
                     while (max >= n and can[n] != ']'):
                        l1.append(can[n])
                        n = n + 1
                     if can[n] == ']':
                        nestdict[nestkey] = l1
                  # nothing to do with blacket parens.
                  else:
                     l0.append(can[n])
                  n = n + 1
                  # [{'¤Ã¤Æ' : ['Çã', '¾¡'], '¤Ã¤¿' : ['Çã', '¾¡']},'Çã', '¾¡']
                  #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ^^^^^^^^^^
                  #        n e s t d i c t (key is okurigana)      ,    L0
                  self.assoc[key] = [nestdict] + l0
      input.close

   def purge_word(self, word):
      try:
         self.assoc[self.henkan_key].remove(word)
      except ValueError:
         pass
      if not self.assoc[self.henkan_key]:
         self.delete_from_keyword_list()
   
   def update(self, word):
      self.update_keyword_list()
      if not self.okurigana:
         try:
            self.assoc[self.henkan_key].remove(word)
         except ValueError:
            pass
         self.assoc[self.henkan_key][0:0] = [word]
      else:
         try:
            self.assoc[self.henkan_key][1:].remove(word)
         except ValueError:
            pass
         self.assoc[self.henkan_key][1:][0:0] = [word]
         nestlist = self.assoc[self.henkan_key][0][okurigana]
         if nestlist:
            try:
               nestlist.remove(word)
            except ValueError:
               pass
            nestlist[0:0] = word
            
   def save(self):
      print('Saving %s...' % self.filename)
      tempfile = gettempdir() + '/' + gettempprefix() + basename(self.filename)
      if not self.do_save(tempfile):
         sys.stderr.write('Failed to save new dictionary!\n')
         return 0
      else:
         try:
            os.rename(expanduser(self.filename), expanduser(self.filename + '.BAK'))
            os.rename(tempfile, expanduser(self.filename))
            print('Saving %s...done!' % self.filename)
            return 1
         except:
            os.unlink(tempfile)
            return 0
         
   def do_save(self, tempfile_name):
      temp = open(tempfile_name, 'w')
      temp.write(';; okuri-ari entries.\n')
      wrote = 0
      for key in self.okuri_ari:
         cands = self.assoc[key]
         if cands != [{}]:
            # for part nothing to do with brackets.
            cands_dumped = key + ' /' + joinfields(cands[1:], '/') + '/'
            # for part with brackets.
            for okurigana in cands[0].keys():
               cands_dumped = cands_dumped + '[' + okurigana + '/' + \
                              joinfields(cands[0][okurigana], '/') + '/]/'
            cands_dumped = cands_dumped + '\n'
            temp.write(cands_dumped)
            wrote = 1
      temp.write(';; okuri-nasi entries.\n')
      for key in self.okuri_nasi:
         cands = self.assoc[key]
         if cands != []:
            temp.write(key + ' /' + joinfields(cands, '/') + '/\n')
            wrote = 1
      temp.close 
      newsize = getsize(expanduser(tempfile_name))
      if (wrote == 0) or (newsize == 0):
         sys.stderr.write('New dictionary will be null file!  Stop saving!\n')
         return 0
      oldsize = getsize(expanduser(self.filename))
      # XXX
      if (newsize >= oldsize):
         return 1
      else:
         try:
            reply = raw_input('New dictionary will be %d bytes smaller.  Do you want to continue? ' \
                              % abs(newsize - oldsize))
            reply = lower(strip(reply))
         except EOFError:
            reply = 'no'
         if reply in ('y', 'yes'):
            return 1
         else:
            return 0
 
   # keyword utilities (mainly used for saving dictionary and completion)
   def delete_from_keyword_list(self):
      try:
         if not self.okurigana:
            self.okuri_nasi.remove(self.henkan_key)
         else:
            self.okuri_ari.remove(self.henkan_key)
      except ValueError:
         pass
      
   def update_keyword_list(self):
      # XXX this may require relatively higher cost than a native hash dictionary...
      if not self.okurigana:
         try:
            self.okuri_nasi.remove(self.henkan_key)
         except ValueError:
            pass
         self.okuri_nasi[0:0] = [self.henkan_key]
      else:
         try:
            self.okuri_ari.remove(self.henkan_key)
         except ValueError:
            pass
         self.okuri_ari[0:0] = [self.henkan_key]

#if __name__ == '__main__': SkkPrivateDictionary.setup_dictionary('/home/minakaji/.skk-jisyo.euc')

## skkdict.py ends here
