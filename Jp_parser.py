from treelib import Node, Tree
import csv

Adjective = open("./mecab-ipadic-2.7.0-20070801/Adj.csv", "r", encoding="utf-8", errors="", newline="" )
f = csv.reader(Adjective, delimiter=",", doublequote=True, lineterminator="\r\n", quotechar='"', skipinitialspace=True)

def test():
    pass
    for i in f:
        print(i[0])
    # tree = Tree()
    # tree.create_node("Harry", "harry")  # root node
    # tree.create_node("Jane", "jane", parent="harry")
    # tree.create_node("Bill", "bill", parent="harry")
    # tree.create_node("Diane", "diane", parent="jane")
    # tree.create_node("Mary", "mary", parent="diane")
    # tree.create_node("Mark", "mark", parent="jane")
    # tree.show()

class Parser(Node):
    def __init__(self):
        pass

if __name__ == "__main__":
    test()

'''
参考文献
https://techlife.cookpad.com/entry/2016/05/11/170000
'''
