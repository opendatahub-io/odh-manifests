from kafka import KafkaProducer
import time
import random
import os
import json

for i in range(10):
    time_slept = random.uniform(0,3)
    time.sleep(time_slept)
    producer=KafkaProducer(bootstrap_servers='odh-message-bus-kafka-bootstrap.%s.svc.cluster.local:9092' % os.environ['NAMESPACE'])
    producer.send("test",json.dumps(f"Producer produced a message").encode('utf-8'))
    producer.flush()
