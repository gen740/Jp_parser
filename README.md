# 日本語形態素解析用のプログラム

## 目的
　日本語の形態素分析は、Google検索に置いて、検索を絞るために使われたり、IMEなど
の変換プログラムにおいて、候補を絞るために使われている。形態素解析でよく使われ
る。プログラムはmecabと呼ばれるプログラムで、京都大学[*1]で作られたプログラムで
ある。

　と言うことで、今回は日々接することの多い変換に使われる形態素解析のプログラム
をmecabを参考にして実装してみた。

　Mecabで用いられているのは、最小コスト法による形態素解析である。形態素解析は、
辞書に基づいて文章を細かく分割したのちに、それらをツリー構造のコンテナに格納し
自分の単語コスト、それと連結コストが最小になる枝を選ぶことで得られる。

　今回は、辞書を作るのはとても手間であり、連結コストを定義するのも大変であった
ので、Mecabに内蔵されている辞書を用いた。

　なお、このプログラムはたった十単語の文章でも、解析するのに1分ほどかかってしまう。だが、
このプログラムでは、最小コスト法の理解を深めるために高速化の工夫はせずに、
プログラム自体が簡潔になるように作った。

　なので、パースできる文章も一文単位であり（もっとも、段落の文章は『。』
を目当てに文章ごとに分割するのはそこまで苦ではないのであるが）出力も
単語ごとに『分かち書き』をした出力をしたりせず、辞書にある情報
そのままの情報を表示させるようにし、内部処理の様子もprintさせるようにした。

## 実行
　このプログラムをモジュールとしてインポートし

```python
form Jp_parser import Parser

s = Parser('日本語のテキストを書いてください')
result = s.analyze()
print(result)
```

から実行できます。

実行結果は
```
コスト-316 	 --- 日:本語のテキストを書いてください
---------------------------------------
コスト-316 	 --- 日:本語のテキストを書いてください
コスト8159 	 --- 本:語のテキストを書いてください
---------------------------------------
コスト-316 	 --- 日:本語のテキストを書いてください
コスト8159 	 --- 本:語のテキストを書いてください
コスト14168 	 --- 語:のテキストを書いてください
---------------------------------------
コスト-316 	 --- 日:本語のテキストを書いてください
コスト8159 	 --- 本:語のテキストを書いてください
コスト14168 	 --- 語:のテキストを書いてください
コスト21559 	 --- の:テキストを書いてください
---------------------------------------
コスト-316 	 --- 日:本語のテキストを書いてください
コスト8159 	 --- 本:語のテキストを書いてください
コスト14168 	 --- 語:のテキストを書いてください
コスト21559 	 --- の:テキストを書いてください
コスト28925 	 --- テキスト:を書いてください
---------------------------------------
コスト-316 	 --- 日:本語のテキストを書いてください
コスト8159 	 --- 本:語のテキストを書いてください
コスト14168 	 --- 語:のテキストを書いてください
コスト21559 	 --- の:テキストを書いてください
       ....
       ....
コスト7552       --- テキ:ストを書いてください
コスト11130      --- スト:を書いてください
コスト13010      --- ス:トを書いてください
コスト-283       --- 日本語:のテキストを書いてください
コスト-952       --- 日本:語のテキストを書いてください
---------------------------------------
コスト-952       --- 日:本語のテキストを書いてください
コスト3829       --- 本:語のテキストを書いてください
コスト-4775      --- 語:のテキストを書いてください
コスト-5814      --- の:テキストを書いてください
コスト7552       --- テキスト:を書いてください
コスト6121       --- を:書いてください
コスト9790       --- 書:いてください
コスト18217      --- い:てください
コスト6861       --- て:ください
コスト5090       --- く:ださい
コスト16940      --- だ:さい
コスト19018      --- さ:い
コスト17029      --- い:
コスト20674      --- さい:
コスト17373      --- ださ:い
コスト13206      --- くだ:さい
コスト11867      --- くださ:い
コスト6621       --- ください:
コスト10562      --- てく:ださい
コスト18217      --- いて:ください
コスト6370       --- 書い:てください
コスト7552       --- テキ:ストを書いてください
コスト11130      --- スト:を書いてください
コスト13010      --- ス:トを書いてください
コスト-283       --- 日本語:のテキストを書いてください
コスト-952       --- 日本:語のテキストを書いてください
---------------------------------------
[['ください', '1239', '1239', '10571', '動詞', '非自立', '*', '*', '五段・ラ行特殊', '命令ｉ', 'くださる', 'クダサイ', 'クダサイ'], ['て', '307', '307', '5170', '助詞', '接続助詞', '*', '*', '*', '*', 'て', 'テ', 'テ'], [' 書い', '687', '687', '7883', '動詞', '自立', '*', '*', '五段・カ行イ音便', '連用タ接続', '書く', 'カイ', 'カイ'], ['を', '156', '156', '4183', '助詞', '格助詞', '一般', '*', '*', '*', 'を', 'ヲ', 'ヲ'], ['テキスト', '1285', '1285', '3562', '名詞', '一般', '*', '*', '*', '*', 'テキスト', 'テキスト', 'テキスト'], ['の', '1310', '1310', '5893', '名詞', '非自立', '一般', '*', '*', '*', 'の', 'ノ', 'ノ'], ['日本語', '1285', '1285', '276', '名詞', '一般', '*', '*', '*', '*', '日本語', 'ニホンゴ', 'ニホンゴ'], []]
```

のようになります。

```zsh
python Jp_parser.py
```

からもでも実行できます。

## 仕組み

　日本語の文章の構文解析でまず課題となるのは、単語分解の手順である。英語であるなら
必ず単語は空白によって区切られるが、日本語の場合は単語の区切りとなる文字がなく
単語の区切り方が複数の解釈がある。
　日本語の形態素解析を難しくしているのは、この単語ごとに分解することが難しいからである。

　日本語の単語分解をするためには、辞書からノードを作りそれを下に解析する必要がある。
しかし、品詞等も含めると「あい」という言葉にさえ、「愛」「会い」「藍」などとたくんさんの
解釈があり、文に対してそれらを全て求めるのは計算コストが高い。

　ここでは、動的計画法を用いてそれぞれのノードでの最小コストを算出してから
そのコストが最終的に一番低くなるものを文末から解析している。
　各ノードには複数の子と、一つの親からなり親をたどることで必ず一文をふくげんできるようにしている。

　動的計画法における一次データの保存では、単語自体のデータとそれが
どこに現れるのかというデータが必要になる。ここでは、簡単のために
＜現れた単語＞:＜単語から文末までの残りの文字＞　を辞書のキーとして利用した。
　
　こうすることで、最終的に更新された辞書では、「:」がキーの最後に現れるかどうかで
それが最終ノードであるかどうか判断できる。このプログラムでは形態素解析のプログラムとして
いかに簡潔に実装するかを目的としているので高速化や精度（最小コスト法しか用いていないこと）
から、あまり求めていない。長い文章にはそれ相応の時間がかかる上に、精度もあまり出ない。

## 課題

　このプログラムでは、実行時間が長いこと、そして未定義の単語などに対応できてい
ないなど、課題がある。プログラムの実行が長いのは単語ごとに分解する際に、毎回辞
書にアクセスしている点である。
　これを改善するには、単語ごとにハッシュを作りアクセスを簡単にした上で、まず初
めに出現する単語のデータだけを抽出してからパースする必要がある。

　参考にした、mecabでは各パラメータの再学習もできるほか、C言語で実装されていた
りするのでとても高速に動く、実用としては自分で実装するよりもmecabを用いた方がい
い、なおpythonで実装された形態素解析ようのプログラムにはJanomeというものもあ
り、これもmecabの辞書の用いて動いているようである。

参考文献
[MeCab: Yet Another Part-of-Speech and Morphological Analyzer](https://taku910.github.io/mecab/)
[日本語形態素解析の裏側を覗く！MeCab はどのように形態素解析しているか](https://techlife.cookpad.com/entry/2016/05/11/170000)

