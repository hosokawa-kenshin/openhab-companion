# people-counter
## Summary
+ people-counter ではカメラや bluetoothセンサなどを用いることで，在室人数を推定するプログラムを管理している．

## Requirements
+ Python 3.x

## カメラ映像を用いた在室人数の推定
カメラ映像を用いた在室人数の推定は [YOLOv5](https://github.com/ultralytics/yolov5) のプログラムを主に使用している．

### Install
pip を使用する場合

 `$ pip3 install -r requirements.txt`


pipenv を使用する場合

  `$ pipenv install`

### How to Use
```
$ pipenv shell   # pipenv を使用する場合のみ
$ python3 detect.py --source <source_name>
```

上記のうち，`<source_name>`には例として以下のような内容が指定できる．
1. カメラのデバイスID(0や1，2など)
2. 画像ファイルや動画ファイル
3. ストリーミングで動画を公開しているURL

#### MQTT で在室人数を送信する場合
以下のオプションをコマンドの引数に追加し，実行することで MQTT で在室人数を送信できる．
+ `--mqtt-server <mqtt_server_domain>`
+ `--topic_name <mqtt_topic_name>`
