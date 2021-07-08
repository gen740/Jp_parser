from Sample_data import Sample
import numpy as np
import csv
from typing import List, Optional


# Mecabの全辞書
dictList = ['./Dict/Adj.csv', './Dict/Adnominal.csv', './Dict/Adverb.csv',
            './Dict/Auxil.csv', './Dict/Conjunction.csv', './Dict/Filler.csv', './Dict/Interjection.csv',
            './Dict/Noun.adjv.csv', './Dict/Noun.adverbal.csv', './Dict/Noun.csv',
            # './Dict/Noun.demonst.csv', './Dict/Noun.nai.csv', './Dict/Noun.name.csv',
            # './Dict/Noun.number.csv', './Dict/Noun.org.csv', './Dict/Noun.others.csv',
            # './Dict/Noun.place.csv', './Dict/Noun.proper.csv', './Dict/Noun.verbal.csv',
            './Dict/Others.csv', './Dict/Postp-col.csv', './Dict/Postp.csv',
            './Dict/Prefix.csv', './Dict/Suffix.csv', './Dict/Symbol.csv', './Dict/Verb.csv']

# それを一つのデータに統合する
# 参照用
WordDict = []
for i in dictList:
    with open(i) as fp:  # 形容詞
        data = list(csv.reader(fp))
    WordDict.extend(data)

# 検索用
ForSearch = [i[0] for i in WordDict]
with open('./Dict/matrix.def') as f:
    data = list(csv.reader(f, delimiter=' '))
Matrix = data
del Matrix[0]

# def _toSentence(str):
#     '''
#     「。」を頼りに、文に分ける
#     '''
#     sentences = str.split('。')
#     return sentences


def _get_adcost(left: int, right: int):
    return int(Matrix[left * 1316 + right][2])


def test():
    print(_get_adcost(24, 238))
    # print(len(Dict))
    # data = 'すもももももももものうち'
    # indexes = [i for i, x in enumerate(ForSearch) if data.startswith(x)]
    # for i in indexes:
    #     print(i)
    #     print(WordDict[i])
    # print('どこ' in Sample)


class Node(object):
    ''' ノード '''

    def __init__(self, s: str, word: str = '', left: int = -1,
                 right: int = -1, cost: int = 0, parent = None):
        self.parent: Optional[Node] = parent
        self.children: List[Optional[Node]] = []
        self.left: int = left
        self.right: int = right
        self.cost: int = cost
        self.total_colt: int
        self.word: str = word
        self.stack: list = []
        self.s: str = s

    def __str__(self):
        result = f'\
            文章  　　　　{self.s}\n\
            自単語データ  {self.word}\n\
            自単語コスト  {self.cost}\n\
            左文脈ID      {self.left}\n\
            右文脈ID      {self.right}\n\
            '
        return result

    def parse_children(self):
        if self.s == '':
            self.children = [None]
            return
        indexes = [i for i, x in enumerate(ForSearch) if self.s.startswith(x)]
        for i in indexes:
            data = WordDict[i]
            word = self.s[len(data[0]):]
            child = Node(
                word,
                data[0],
                int(data[1]),
                int(data[2]),
                int(data[3]))
            # print(child)
            # child.parse_children()
            self.children.append(child)
        # print(self.children)


class Parser(object):
    def __init__(self, s):
        self.node = Node(s)
        self.s = s

    def analyze(self) -> str:
        return ''


def main():  # メインテスト
    sentence = '地元'
    parser = Parser(sentence)
    print(parser.analyze())

    n = Node(sentence)
    n.parse_children()


if __name__ == "__main__":
    test()
    main()
    pass

'''
参考文献
https://techlife.cookpad.com/entry/2016/05/11/170000
'''
