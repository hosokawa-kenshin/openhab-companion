# people-counter
## Summary
+ people-counter ではカメラや bluetoothセンサなどを用いることで，在室人数を推定するプログラムを管理している．

## カメラ映像を用いた在室人数の推定
カメラ映像を用いた在室人数の推定は [YOLOv5](https://github.com/ultralytics/yolov5) のプログラムを主に使用している．

## bluetooth センサーを用いた在室人数の推定
bluetooth センサーを用いた在室人数の推定は，各人が持つスマートフォンのbluetoothのMACアドレスを用いて，在室人数を推定している．

## Beacon 情報を用いた在室情報推定
Beacon 情報を用いた在室情報推定は各人が持つ Beacon が発する情報を MQTT で Sub し，在室人数を推定している．

