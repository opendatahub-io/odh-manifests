from kafka import KafkaConsumer
import os
import json

consumer = KafkaConsumer("test",group_id="test-group",auto_offset_reset='earliest',bootstrap_servers='odh-message-bus-kafka-bootstrap.%s.svc.cluster.local:9092' % os.environ['NAMESPACE'])

try:
    for record in consumer:
        msg = record.value.decode('utf-8')
        print(msg)
        if msg == "\"Producer produced a message\"":
            break
except KeyboardInterrupt:
    pass
finally:
    # Don't forget to clean up after yourself!
    print("Closing KafkaConsumer...")
    consumer.close()

print("done")
