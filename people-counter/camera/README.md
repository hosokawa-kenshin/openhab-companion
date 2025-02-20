# カメラ映像を用いた在室人数の推定
カメラ映像を用いた在室人数の推定は [YOLOv5](https://github.com/ultralytics/yolov5) のプログラムを主に使用している．

### Requirements
+ Python 3.x

### ファイル構成
- **Pipfile**
  `pipenv` を用いて依存関係を管理するためのファイル

- **Pipfile.lock**
  依存関係のバージョンを固定するためのロックファイル

- **README.md**
  本ドキュメントファイル

- **requirements.txt**
  `pip` を使用して必要なパッケージをインストールするためのファイル

- **camera_people-counter.py**
  本プロジェクトのメインスクリプト．カメラ映像の取得，YOLOv5 を用いた物体検出，および在室人数の推定処理を実行

- **models/**
  物体検出に用いる学習済みモデルや関連ファイルを格納するディレクトリ

- **utils/**
  `camera_people-counter.py` を動作させる上で必要なユーティリティ関数や補助スクリプトが配置されているディレクトリ

- **scripts/**
  補助的なスクリプトが配置されているディレクトリ
  - **launch.sh**
    プロジェクトを起動するためのシェルスクリプト

- **systemd_conf/**
  Linux の systemd サービス用の設定ファイルが格納されているディレクトリ

## How to Use

### Install
pip を使用する場合

 `$ pip3 install -r requirements.txt`

pipenv を使用する場合

  `$ pipenv install`
### camera_people-counter.py の実行

`camera_people-counter.py` を実行し、必要に応じて各種オプションを指定

```bash
$ python3 camera_people-counter.py --mqtt-server MQTT_SERVER --mqtt-port MQTT_PORT --source <source_name>  [--weights MODEL_DATA] [--imgsz IMAGE_SIZE] [--conf-thres CONFIDENCE] [--iou-thres IOU_THRESHOLD] [--device DEVICE]  [--mqtt-topic MQTT_TOPIC]  [--mqtt-interval MQTT_INTERVAL]
```

### オプション一覧

- `--mqtt-server MQTT_SERVER`  
  MQTT サーバのドメインまたは IP アドレスを指定

- `--mqtt-port MQTT_PORT`  
  MQTT サーバのポート番号を指定

- `--source SOURCE_DATA`  
  画像/動画ファイル、またはストリームURL、カメラのデバイスIDを指定
- `--conf-thres CONFIDENCE`  
  推論時の信頼度の閾値を設定

- `--device DEVICE`  
  使用するデバイスを指定

- `--imgsz IMAGE_SIZE`  
  推論時の画像サイズを指定

- `--iou-thres IOU_THRESHOLD`  
  Non-Maximum Suppression (NMS) の IoU 閾値を設定

- `--mqtt-interval MQTT_INTERVAL`  
  MQTT での送信間隔（秒）を指定

- `--mqtt-topic MQTT_TOPIC`  
  MQTT で送信するトピック名を指定

- `--weights MODEL_DATA`  
  モデルのパスを指定（default: `yolov5s.pt`）


