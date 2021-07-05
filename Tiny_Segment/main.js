require(["TinySegmenter"], function (#dependencies2) {
// sample code from http://chasen.org/~taku/software/TinySegmenter/
var segmenter = new TinySegmenter(); // インスタンス生成
var segs = segmenter.segment("私の名前は中野です"); // 単語の配列が返る
console.log(segs.join(" | ")); // 表示
