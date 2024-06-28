# Beacon 情報を用いた在室情報推定
各人が持つ Beacon が発する情報を MQTT で Sub し，在室情報を推定する Beacon Aggregator．

## 使い方
1. [sheetq](https://github.com/nomlab/sheetq)をインストール，認証を行い，使用可能な状態にする．
2. 設定ファイルを作成する．
    ```bash
    cp settings.example settings
    vim settings
    ```
    設定ファイル内に以下の変数があるため，各環境に合わせて設定する．
    * MQTT_HOST: MQTT のドメイン名
    * MQTT_PUB_TOPIC: 在室状態をパブリッシュするトピック名
    * MQTT_SUB_TOPIC: Mediator のログをサブスクライブするトピック名
    * INTERVAL: 何秒おきにログを確認するか
    * LOG_FILE: ログファイルの置き場所 (空のままだと，このスクリプトと同じディレクトリに `beacon.log` というファイルが作成・使用される)
3. そのまま動かす場合
    ```bash
    ./beacone.sh
    ```
4. systemd 経由で使う / 自動起動させたい場合
    1. systemd の設定ファイルを配置する
        ```bash
        sudo cp systemd/beacone.service /etc/systemd/system/
        sudo vim /etc/systemd/system/beacone.service
        ```
        beacone.service ファイルを各環境に合わせて設定する．
    2. (Optional) sheetq や Ruby がグローバルで使用できない場合
        ```bash
        sudo cp systemd/beacone_environment /etc/environment/
        sudo vim /etc/environment/beacone_environment
        ```
        beacone_environment ファイルに Ruby や sheetq が使えるパスを記述する．
    3. systemd から起動
        ```bash
        sudo systemctl start beacone.service
        ```
    4. (Optional) 自動起動する場合
        ```bash
        sudo systemctl enable beacone.service
        ```

## 処理内容
1. MQTTをサブスクライブし，Mediatorのデータをログファイルに記録する．
2. Google スプレッドシートから，各人の Beacon UUID を取得する．
3. ログを定期的に確認し，各人のログの情報から在室状態を判断する．
4. 在室/不在をMQTTでパブリッシュする．

## Subscribe されるデータの形式
データは以下の json 形式で受信されることが想定される．
```json
{"uuid": "aabbccdd-eeff-0011-2233-445566778899","major":1,"minor":200,"rssi":-50}
```

## Publish するデータの形式
以下の json 形式で送信する．
status は，各人が在室する部屋番号を表す．
```json
{"<account_name>" : "<status>"}
```
