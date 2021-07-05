from janome.tokenizer import Tokenizer

t = Tokenizer()

s = 'すもももももももものうち'

for token in t.tokenize(s):
    print(token)
