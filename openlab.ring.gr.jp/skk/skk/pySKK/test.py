#!/usr/bin/env python
import skkdict

dict_name = '~/.skk-jisyo.euc'
midasi = '�ؤ󤫤�'
kakutei_word0 = '�Ѵ�'
kakutei_word1 = '�ִ�'

dict = skkdict.PrivateDictionary()
dict.setup(dict_name)

print('searching %s...' % midasi)
for c in dict.search(midasi, 0):
    print c
print ''    

dict.update(kakutei_word0)
print('kakutei done with %s' % kakutei_word0)

#dict.purge_word('purge_word')
#for c in dict.search(midasi, 0):
#    print c

print('searching %s...' % midasi)
for c in dict.search(midasi, 0):
    print c
print ''    

dict.update(kakutei_word1)
print('kakutei done with %s' % kakutei_word1)

#print ''    
#print 'dict.filename is ' + dict.filename 
#print ''    
#print 'dict.henkan_key is ' + dict.henkan_key
#print ''    
dict.save()
