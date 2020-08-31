#!/bin/bash

python3 ./producer/producer.py &
python3 ./consumer/consumer.py
