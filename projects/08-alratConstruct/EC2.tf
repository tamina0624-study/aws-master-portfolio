

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "EC2-High-CPU-Utilization-Lab"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "EC2のCPU使用率が30%を超えました（High・学習用）"
  alarm_actions       = [aws_sns_topic.high_alert.arn]
  dimensions = {
    InstanceId = data.terraform_remote_state.basic_infra.outputs.ec2_instance_id
  }
  tags = {
    Importance = "High"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_low" {
  alarm_name          = "EC2-Low-CPU-Utilization-Lab"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "EC2のCPU使用率が10%を超えました（Low・学習用）"
  alarm_actions       = [aws_sns_topic.low_alert.arn]
  dimensions = {
    InstanceId = data.terraform_remote_state.basic_infra.outputs.ec2_instance_id
  }
  tags = {
    Importance = "Low"
  }
}

resource "aws_sns_topic" "high_alert" {
  name = "high-alert-topic-lab"
}

resource "aws_sns_topic" "low_alert" {
  name = "low-alert-topic-lab"
}

variable "ec2_instance_id" {
  description = "監視対象EC2のID"
  type        = string
}
