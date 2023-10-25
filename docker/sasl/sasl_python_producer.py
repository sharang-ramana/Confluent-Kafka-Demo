from confluent_kafka import Producer

# Kafka broker configuration
kafka_config = {
    'bootstrap.servers': 'localhost:9092',  # Replace with your Kafka broker address
    'security.protocol': 'SASL_PLAINTEXT',       # Use SASL_PLAINTEXT if required
    'sasl.mechanism': 'PLAIN',              # Use the appropriate SASL mechanism if required
    'sasl.username': 'alice',       # Replace with your SASL username if required
    'sasl.password': 'alice-secret',       # Replace with your SASL password if required
}

# Kafka topic to produce to
kafka_topic = 'test_topic'  # Replace with the desired Kafka topic name

# Sample data to produce
sample_data = [
    'Message 1',
    'Message 2',
    'Message 3',
    # Add more messages as needed
]

def delivery_report(err, msg):
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}')

if __name__ == '__main__':
    # Create a Kafka producer instance
    producer = Producer(kafka_config)

    for data in sample_data:
        # Produce a message to the Kafka topic
        producer.produce(kafka_topic, value=data, callback=delivery_report)

    # Wait for any outstanding messages to be delivered and delivery reports received
    producer.flush()
