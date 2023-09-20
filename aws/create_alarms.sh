#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it and configure your credentials."
  exit 1
fi

# Specify the SNS topic ARN
sns_topic_arn="sns_topic_arn"

# Get a list of all SQS queue URLs
queue_urls=$(aws sqs list-queues --output text --query 'QueueUrls[]')

# Loop through each queue URL
for queue_url in $queue_urls; do
  # Extract the queue name from the URL
  queue_name=$(basename "$queue_url")

  # Define the CloudWatch alarm name
  alarm_name="sqs-${queue_name}-High-ApproximateAgeOfOldestMessage"

  # Check if the alarm already exists
  alarm_exists=$(aws cloudwatch describe-alarms --alarm-names "$alarm_name" --output text --query 'MetricAlarms[0].AlarmName')

  if [ "$alarm_exists" = "None" ]; then
    # Create the CloudWatch alarm since it doesn't exist
    aws cloudwatch put-metric-alarm \
      --alarm-name "$alarm_name" \
      --actions-enabled \
      --alarm-actions "$sns_topic_arn" \
      --metric-name "ApproximateAgeOfOldestMessage" \
      --namespace "AWS/SQS" \
      --statistic "Average" \
      --period 60 \
      --comparison-operator "GreaterThanThreshold" \
      --threshold 300 \
      --evaluation-periods 5 \
      --datapoints-to-alarm 5 \
      --dimensions "Name=QueueName,Value=$queue_name"

    if [ $? -eq 0 ]; then
      echo "Alarm '$alarm_name' created for SQS queue '$queue_name'"
    else
      echo "Failed to create alarm for SQS queue '$queue_name'"
    fi
  else
    echo "Alarm '$alarm_name' already exists for SQS queue '$queue_name'"
  fi
done

echo "All alarms checked or created successfully!"
