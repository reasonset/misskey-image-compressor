# Misskey 画像圧縮ツール

## 概要

本ツールはマイクロブログSNSソフトウェア "Misskey" をターゲットとし、投稿時にドライブ容量と帯域にやさしい縮小を行うツールである。

## 必要なもの

* Bash
* file
* ImageMagick
* opegoptim
* pngquant
* cwebp (WebP圧縮時)
* avifenc (AVIF圧縮時)

## 使い方

```
misyimg.bash [-aw] [-s<px>] [-p<pict|ss|photo|photohd>] sourcefile
```

圧縮されたファイルはカレントディレクトリ内に生成される。カレントディレクトリ内にsourcefileがある状態で実行することはできない。

## オプション

|option|意味|
|------|----------------------------------------------|
|`-a`|AVIFに変換する|
|`-w`|WebPに変換する|
|`-s<px>`|長辺のピクセル長を`<px>`に制限する。デフォルトは`1000`|
|`-p<profile>`|画像タイプを`pict`(イラスト), `ss`(テキスト主体のスクリーンショット), `photo`(共有のために投稿する写真), `photohd`(作品としての写真)のいずれかから指定する。指定しない場合、より強く圧縮を重視する|

## 変換ルール

* `-a` または `-w` オプションが指定された場合、それに従う
* ソースファイルがPNGであればPNGに、JPEGであればJPEGに変換する

## 注意点

本ツールはMisskeyの挙動にフォーカスしている。

PNGまたはJPEGは、Misskey側で表示用ファイルを生成させないため、すべてのメタデータを除去する。

AVIFはICCプロファイルとXMPメタデータを、WebPはICCプロファイルを維持する。

## 使い方の解説

### 導入パート

#### Linux

以下の手順で準備を行う

1. 必要なソフトウェアをインストールする
2. `mskyimg.bash` を実行パス下のディレクトリにコピーする

#### Mac OS X

Homebrewを使って必要なソフトウェアをインストールする。

```
% brew install imagemagick
% brew install jpegoptim
% brew install pngquant
% brew install libavif
% brew install webp
```

Macの場合はこのようなユーザースクリプトを置く既定の場所がなさそうなので、作ることになるかもしれない。
たとえば、

```
mkdir ~/bin
```

のようにディレクトリを用意したら、`~/.bash_profile`ファイルに

```
export PATH=$HOME/bin:$PATH
```

のように書いておくのである。

その上で、そのようなディレクトリ(例では`~/bin`)に`mskyimg.bash`をコピーして置く。

#### Windows

WindowsではBash環境が必要である。
基本的にはBashが利用可能であり、次のコマンドがBashから実行可能であれば動作するはずだ。

* `convert`
* `file`
* `jpegoptim`
* `pngquant`
* `cwebp`
* `avifenc`

このスクリプトはこれ以外のコマンドを呼ばない。
そのため、これを満たすことができるのであればMSYS2環境(例えばGit Bash)を使ってもいいし、WSLでも良い。
本説明ではWSLのような「Windowsファイルシステムへアクセス可能なLinux環境」を想定する。

基本的にソフトウェア側はWindowsのものを使って支障がない。
もちろん、Linux環境であると考え、Linux用パッケージを導入してもいいが、動作はWindowsネイティブのほうが速い。

ただ、`jpegoptim`と`avifenc`に関してはWindows上で用意するのが少しむずかしい。
説明が面倒になるので、ここではWSL環境を用意し、OpenSUSE Leap環境で利用することを想定する。
WSLおよびWSLのOpenSUSEを導入する手順については各々調べてほしい。
もちろん、あなたが応用が効くのならUbuntuを使っても構わない。

(WSLの導入自体は、最近のWindowsは管理者として`wsl --install`を実行するだけでできるはずだ。)

まずは

```bash
sudo zypper update
```

して更新した後、

```bash
sudo zypper install ImageMagick jpegoptim pngquant avif-tools libwebp-tools
```

すれば準備完了。
あとはこのOpenSUSE環境からなら、Linuxと同じ扱いができる。

Windows上のCドライブは`/mnt/c`に生えている。
Windowsと違い、ディレクトリセパレータは(`\`ではなく)`/`であることに注意が必要だ。
スペースの多いWindowsのディレクトリは扱いにくいだろう。

扱いを楽にするという意味では1度

```bash
ln -s /mnt/c/Users/foo/Pictures ~/
```

のようにすると、OpenSUSE上のホーム直下にWindowsのマイピクチャが`Pictures`として生えるので、扱いはかなり楽になる。

### コマンドの使い方

圧縮手順は次のとおり

1. 適当な作業ディレクトリを用意する (例: `mkdir ~/msky`)
2. 作業ディレクトリに移動する (例: `cd ~/msky`)
3. スクリプトを実行する (例: `mskyimg.bash ~/photo/fooimage.png`)

コマンドを実行する方法については、分からないのであれば各々調べて欲しい。
Windowsに関してはWSL上で実行する必要があり、端末起動後はWindowsのコマンドではなくLinuxのコマンドの使い方に従う点に注意が必要。

コマンド実行にあたり、作業ディレクトリを作成し、`cd`コマンドによってそこに移動しておく必要がある。

`mskyimg.bash`の引数は、元となる画像ファイルである。

コマンドと画像ファイルの間に「オプション」を置くことができる。
このオプションによって動作が変化する。

例えば、`a`オプションを指定するには次のようにする。

```bash
mskying.bash -a ~/photo/fooimage.png
```

`-s`オプションと`-p`オプションはオプション引数を取る。
これは、値をこのオプションに続いて記入する。

コマンドに慣れた人も注意が必要だ。Bashの`getopts`を使っているため、*オプションとオプション引数の間にスペースを入れることはできない。*

次の例では`s`オプションの値として`800`を、`p`オプションの値として`ss`を指定している。

```
mskyimg.bash -s800 -pss ~/photo/screenshot.png
```

スクリプトが成功すれば圧縮されたファイルがカレントディレクトリに残る。
失敗した場合はその旨表示される。

## オプション指定についてのアドバイス

### AVIF? WebP?

AVIFとWebPは「Misskeyの負担を無視してドライブ節約を重視する」オプションである。

品質はAVIFのほうが良いが、処理が重い。

また、WebPはまだ品質指定方法がこなれておらず、最適化が甘いためあまり品質が高くない。

Misskeyや他のユーザー、他のインスタンスの負担を考慮するのであれば、これらのオプションは指定しないほうが良い。

また、AVIFを使用するためには`avifenc`が、WebPを使用するためには`cwebp`が利用可能である必要がある。

### 画像サイズ

デフォルトは1000pxである。

これは、Misskey上で表示される画像のピクセルサイズを考慮して十分な値である。保存を想定するなら話は変わってくるが、基本的には指定するとしたらそれより小さいサイズのはずだ。

ソースによるが、800や500などを指定することは考えられる。

アイコンが絵文字の場合、256や120を指定することもあるだろう。

### 画像プロファイル

画像プロファイルはAVIFの場合は全く意味がない。

JPEGの場合は`photohd`だけ圧縮を弱め、画質を重視する。

通常、SNSへの投稿データとしてはプロファイルを何も指定しなければ強い圧縮になるため、ほとんどの場合これで望ましいデータが生成される。そのため、指定の必要はない。

指定する場合は以下のような意図が良い。

|profile|意図|
|-------|----------------------------------------------------------|
|pict|イラストレーター向けのオプションであり、視覚的劣化を抑え、ノイズの少ないデータを生成する|
|ss|テキストを撮ったスクリーンショットで、テキストの可読性を低下させないようにデータを生成する|
|photohd|写真家向けのオプションであり、アート品質の写真の雰囲気を損なわないようにデータを生成する|
|photo|芸術的写真向けのオプションであり、綺麗な写真に仕上がるよう圧縮を加減する|
|無指定|投稿向けのオプションであり、サイズ圧縮を重視する|

### 深く考えずに使いたい場合

デフォルト状態は私が投稿時に行う処理に近いため、オプション無指定で問題はないはずだ。

## よくありそうな質問

Q. この説明で使い方がわからなかったらどうしたらいい？

A. Misskeyインスタンスの中に分かる人はいるはずなので、助け合いの精神でお願いしたい。
私に聞かれても答える余裕はないかもしれない。

Q. Linuxでスクリプトの問題により動かない

A. 問題の詳細をIssueに上げてほしい

Q. Windowsでスクリプトの問題により動かない

A. 問題の詳細をIssueに上げてほしい

Q. Macでスクリプトの問題により動かない

A. 問題の詳細をIssueに上げてくれたらもしかしたら対応するかもしれないが、私はMacを持っていないので検証できないので期待はしないで欲しい

Q. READMEの手順が実行できない

A. それがREADMEの間違いであるなら、Issueにどうするべきか上げてくれれば対応するかもしれない

Q. デフォルト値や挙動を変えて欲しい

A. お断りだッ

Q. 結局オプションの設定はどうしたらいいのか

A. 分からないならオプションなんか使わずにソースファイルだけを与えて実行すればいい。それで不満なケースは限定的だ

Q. このスクリプトが何をやっているか分からなくて不安だ

A. [記事を読もう。](http://chienomi.org/articles/linux/202302-misskey-photo-compress.html)
このスクリプトはより高度な要求を満たすためのものだから、別に使わなくても支障はない。ioなら課金してドライブ容量を増やそう

Q. WebPのパラメータが気に入らない

A. WebPのパラメータについては意見を募集している。ぜひ私に言ってほしい

Q. pngquantのパラメータが気に入らない

A. pngquantに関しては私がかなり練っているので、気に入らないことはないと思うのだけど、個人的にどうしても気に入らないのであれば、このスクリプトはGPLで配布されているものだから、パラメータを自分でいじるといい

Q. Misskeyってなに

A. しゅいろﾏﾏhshsレタはす

Q. Misskey用にしか使えないのか

A. Misskey向けになっている要素は、JPEGとPNGにおいてメタデータを全ストリップするようになっているという点にある。これを行うのはMisskeyの挙動によるところなので、他への投稿目的なら適さないかもしれない。
ただ、Misskey向け要素はそれくらいのものなので、別にMisskey以外でも使おうと思えば使える。

Q. なぜこれを作ったのか

A. そもそもは自分でソースに合わせて毎回長々とオプション指定するのが面倒になった(履歴からたどってはいるけれど)からどのみちツール作るつもりであったのだが、
ioで私のドライブ節約に関する記事が定期的にRNされており、ニーズも高いようであること、またアンケートによって実際にそれが確認されたことから作られた。

Q. もっとREADMEで詳しく説明してくれないか

A. 誰か手伝ってくれる人がいればできるかもしれないが、このREADMEを書くのは相当大変だったので容赦してほしい。

Q. 英語のREADMEに説明がないのはなぜ

A. その手間をかける価値を見いだせなかったから。contributeに期待したい。