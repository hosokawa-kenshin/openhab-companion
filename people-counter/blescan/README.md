# bluetooth センサーを用いた在室人数の推定
bluetooth センサーを用いた在室人数の推定は，各人が持つスマートフォンのbluetoothのMACアドレスを用いて，在室人数を推定している．

## 処理内容
1.blescan.sh を起動後にGoogle spread sheet から，各人のスマートフォンのbluetoothのMACアドレスを取得する．
2.各MACアドレスについてhcitool で周辺に存在するか確認し，MQTTでデータを送信する．

## 送信されるデータの形式
データは以下の json 形式で送信される．
```json
{"<account_name>" : "<attendance>"}
```
