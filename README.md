# tbla(Tobu-Bus-Location-API) | [demo on heroku](https://tbla.herokuapp.com)

東武バスOn-Lineが提供する[バス現在位置情報検索（バスロケーション）](http://www.tobu-bus.com/pc/search/s50on_index.php)の出力をパースしてjsonで返却するAPIサーバ


## 概要

東武バスOn-Lineの位置情報検索結果はhtmlとして返却されます。
例えば、大宮駅西口から櫛引方面へのバス位置情報を検索すると、[このような出力](http://210.132.101.180/service/tobu/web_east/main02.jsp?wid=1&gid=405,412&scd=12001&s=12001&e=12007&k=&k2=&k3=)になります（現在位置情報検索というか、あと何分で次のバスが到着するかという情報を確認できます）。

本APIでは東武バスOn-Lineが出力するhtml画面をパースし、下記のようなjson形式でバス到着までの時刻（分）を返却します。

2014年11月13日の22:42に実行した結果は以下の通り
```
{"called_at":"2014-11-13 22:42:48 +0900","as_at":"22:42","departure":"12001","stop":"12007","duration":"14"}
```

あと14分で大宮駅西口バス停に櫛引方面行きのバスがくることが分かります。

東武バスOn-LineのURLを調べるとIDのようなものが含まれており、例えば、12001が大宮駅西口、12007が櫛引というように、各バス停に対応しています。
APIでは、このバスIDをそのまま流用します。


## 仕様

### リクエストURL

[GET] https://tbla.herokuapp.com/[departure]/[stop]

departureとstopには東武バスのバス停IDを指定します。


### URLのサンプル

大宮駅西口（ID:12001)から櫛引（ID:12007）方面のバスの位置情報を取得する例は以下の通り

https://tbla.herokuapp.com/12001/12007


### JSON定義

|項目      |説明                                        |
|---------|-------------------------------------------|
|called_at|APIを呼び出した時刻（APIが動作しているサーバの時刻）|
|as_at    |APIを呼び出した時刻（東武バスサーバ側の時刻）      |
|departure|出発バス停ID                                 |
|stop     |到着バス停ID                                 |
|duration |次のバスが到着するまでの時間（分）                |



### 制約事項

#### 次に到着するバスの遅延のみを返却する
東武バスOn-Lineで確認できるバス位置情報は次のバスだけでなく、２つか３つ先ぐらいのバスまで含まれる場合があります。
このAPIサーバでは次に到着するバスの情報のみを返します。（今後気が向けば機能追加します）

#### 作者の使うバス停だけが表示されてます
プログラム本体のapp.rbでトップ画面にリンクが表示されるバス停がハードコーディンされてますが、これは単に作者が日頃使ってるバス停というだけです。
リポジトリ内にある`station.txt`が全バス停のIDリストです。（東武バスOn-Lineをスクレイピングして作りました）


## 動かし方

本APIサーバはruby製のsinatraというフレームワークを使って実装しています。

ローカルで動作させるのに必要となるgemは以下のとおり

- bundler
- foreman

本リポジトリをcloneした後、下記のとおり実行すれば。
localhost:5000 でAPIサーバが起動します。（foremanデフォルト設定の場合）
```
$ bundle install --path vendor/bundle
$ foreman start
```

### herokuのタイムゾーン設定

herokuで動作させる場合にタイムゾーンをJSTにする

```
$ heroku config:add TZ=Asia/Tokyo
```


## License
MIT

東武バスOn-Line [バス現在位置情報検索](http://www.tobu-bus.com/pc/search/s50on_index.php) に記載されている注意事項や免責事項もご確認ください。


## Author
[knjcode](https://github.com/knjcode)
