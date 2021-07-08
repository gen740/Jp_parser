import csv
from typing import List, Optional, Dict


# Mecabの全辞書
dictList = ['./Dict/Adj.csv',
            './Dict/Adnominal.csv',
            './Dict/Adverb.csv',
            './Dict/Auxil.csv',
            './Dict/Conjunction.csv',
            './Dict/Filler.csv',
            './Dict/Interjection.csv',
            './Dict/Noun.adjv.csv',
            './Dict/Noun.adverbal.csv',
            './Dict/Noun.csv',
            './Dict/Noun.demonst.csv',
            './Dict/Noun.nai.csv',
            './Dict/Noun.name.csv',
            './Dict/Noun.number.csv',
            './Dict/Noun.org.csv',
            './Dict/Noun.others.csv',
            './Dict/Noun.place.csv',
            './Dict/Noun.proper.csv',
            './Dict/Noun.verbal.csv',
            './Dict/Others.csv',
            './Dict/Postp-col.csv',
            './Dict/Postp.csv',
            './Dict/Prefix.csv',
            './Dict/Suffix.csv',
            './Dict/Symbol.csv',
            './Dict/Verb.csv']

# それを一つのテーブルに統合する

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


def _get_adcost(left: int, right: int):
    return int(Matrix[left * 1316 + right][2])


# 再帰を利用するときに簡単のため、globalに持っておく
prev: Dict = {}


class Node(object):
    ''' ノード '''

    def __init__(self, s: str,
                 word: str = '',
                 left: int = 0,
                 right: int = 0,
                 cost: int = 0,
                 parent=None,
                 total_cost: int = 0,
                 data=[]):
        self.parent: Optional[Node] = parent
        self.children: List[Optional[Node]] = []
        self.left: int = left
        self.right: int = right
        self.cost: int = cost
        self.total_cost: int = total_cost
        self.word: str = word
        self.stack: list = []
        self.data = data
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
        global prev
        if self.s == '':
            self.children = [None]
            return
        indexes = [i for i, x in enumerate(ForSearch) if self.s.startswith(x)]
        for i in indexes:
            data = WordDict[i]
            word = self.s[len(data[0]):]
            total_cost = self.total_cost + \
                _get_adcost(self.left, int(data[2])) + \
                self.cost
            key = data[0] + ':' + word
            if key in prev.keys() and total_cost > prev[key][0]:
                continue
            child = Node(
                word,
                data[0],
                int(data[1]),
                int(data[2]),
                int(data[3]),
                self,
                total_cost,  # TODO
                data
            )
            prev.update({key: [total_cost, child]})
            print(prev)
            print('---------')
            child.parse_children()
            self.children.append(child)


class Parser(object):
    def __init__(self, sentences):
        self.node = Node(sentences)

    def analyze(self) -> List:
        global prev
        self.node.parse_children()
        min: List[Node] = []
        for i in prev.keys():
            if i.endswith(':') and min == []:
                min = prev[i]
            elif i.endswith(':') and prev[i][0] < min[0]:
                min = prev[i]
        print(min[1].data)
        result = [min[1].data]
        parent = min[1]
        while parent.parent is not None:
            result.append(parent.parent.data)
            print(parent.parent.data)
            parent = parent.parent
        print(prev)
        return result


def main():  # メインテスト
    p = Parser('これは日本語の形態素解析用のプログラムです')
    print(p.analyze())
    # p = Parser('これは日本語の形態素')
    # print(p.analyze())


if __name__ == "__main__":
    main()
    pass

'''
参考文献
https://taku910.github.io/mecab/
https://techlife.cookpad.com/entry/2016/05/11/170000
'''
