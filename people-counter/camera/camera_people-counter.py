import argparse
import os
import sys
import time
import requests
import numpy as np
import paho.mqtt.client as mqtt
import torch
from models.common import DetectMultiBackend
from utils.general import LOGGER, check_img_size, non_max_suppression, scale_boxes
from utils.torch_utils import select_device, smart_inference_mode
import cv2

def on_connect(client, userdata, flag, rc):
    LOGGER.info("Connected with result code " + str(rc))

def on_disconnect(client, userdata, rc):
    if rc != 0:
        LOGGER.info("Unexpected disconnection.")
    client.connect()

class MqttClient:
    def __init__(self, server, port, topic):
        self.topic = topic
        self.client = mqtt.Client()
        self.client.on_connect = on_connect
        self.client.on_disconnect = on_disconnect
        self.client.connect(server, port, 60)

    def publish(self, send_string):
        self.client.publish(self.topic, send_string)

@smart_inference_mode()
def run(
        weights='yolov5s.pt',
        source='data/images',
        imgsz=(640, 640),
        conf_thres=0.25,
        iou_thres=0.45,
        device='',
        nosave=False,
        mqtt_topic='',
        mqtt_server='',
        mqtt_port=1883,
        mqtt_interval=10):
    source = str(source)
    device = select_device(device)
    model = DetectMultiBackend(weights, device=device)
    stride, names = model.stride, model.names
    imgsz = check_img_size(imgsz, s=stride)
    if mqtt_server and mqtt_topic:
        mqtt_client = MqttClient(mqtt_server, mqtt_port, mqtt_topic)
    LOGGER.info(f"Starting to fetch frames every 5 seconds from {source}")
    while True:
        try:
            stream = requests.get(source, stream=True, timeout=10)
        except Exception as e:
            LOGGER.warning(f"Failed to access stream {source}: {e}")
            if mqtt_server and mqtt_topic:
                mqtt_client.publish("-1")
                LOGGER.info(f"MQTT message published: -1")
            time.sleep(10)
            continue
        byte_data = bytes()
        for chunk in stream.iter_content(chunk_size=1024):
            byte_data += chunk
            start_idx = byte_data.find(b'\xff\xd8')
            end_idx = byte_data.find(b'\xff\xd9')
            if start_idx != -1 and end_idx != -1:
                jpg_data = byte_data[start_idx:end_idx + 2]
                byte_data = byte_data[end_idx + 2:]
                frame = cv2.imdecode(np.frombuffer(jpg_data, dtype=np.uint8), cv2.IMREAD_COLOR)
                break
        else:
            LOGGER.warning("No frame retrieved from the stream. Retrying in 10 seconds...")
            if mqtt_server and mqtt_topic:
                mqtt_client.publish("-1")
                LOGGER.info(f"MQTT message published: -1")
            time.sleep(10)
            continue
        frame_resized = cv2.resize(frame, (imgsz[1], imgsz[0]))
        im = torch.from_numpy(frame_resized).to(model.device)
        im = im.permute(2, 0, 1).float() / 255.0
        im = im[None]
        pred = model(im)
        pred = non_max_suppression(pred, conf_thres, iou_thres)
        person_count = 0
        for det in pred:
            if len(det):
                det[:, :4] = scale_boxes(im.shape[2:], det[:, :4], frame.shape).round()
                for c in det[:, 5].unique():
                    if int(c) == 0:
                        person_count = int((det[:, 5] == c).sum())
                        LOGGER.info(f"Persons detected: {person_count}")
        if mqtt_server and mqtt_topic:
            mqtt_client.publish(f"{person_count}")
            LOGGER.info(f"MQTT message published: {person_count}")
        time.sleep(1)
    cv2.destroyAllWindows()

def parse_opt():
    parser = argparse.ArgumentParser()
    parser.add_argument('--weights', type=str, default='yolov5s.pt', help='model path')
    parser.add_argument('--source', type=str, default='data/images', help='file/dir/URL or stream URL')
    parser.add_argument('--imgsz', nargs='+', type=int, default=[640], help='inference size h,w')
    parser.add_argument('--conf-thres', type=float, default=0.25, help='confidence threshold')
    parser.add_argument('--iou-thres', type=float, default=0.45, help='NMS IoU threshold')
    parser.add_argument('--device', default='', help='cuda device or cpu')
    parser.add_argument('--mqtt-topic', type=str, default='', help='MQTT topic')
    parser.add_argument('--mqtt-server', type=str, default='', help='MQTT server')
    parser.add_argument('--mqtt-port', type=int, default=1883, help='MQTT port')
    parser.add_argument('--mqtt-interval', type=int, default=10, help='interval for MQTT publishing')
    opt = parser.parse_args()
    opt.imgsz *= 2 if len(opt.imgsz) == 1 else 1
    return opt

def main(opt):
    run(**vars(opt))

if __name__ == "__main__":
    opt = parse_opt()
    main(opt)
