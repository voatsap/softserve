## Autscale policy
resource "aws_autoscaling_policy" "scale_in_softserve" {
        name                   = "autoscale_in_policy_softserve-${var.instance_suffix[count.index]}"
        adjustment_type        = "ChangeInCapacity"
        policy_type            = "StepScaling"
        estimated_instance_warmup = 35
        autoscaling_group_name = "${element(aws_autoscaling_group.asg-softserve.*.name, count.index)}"

        step_adjustment {
        scaling_adjustment = 0
         metric_interval_upper_bound = 1
         }

        step_adjustment {
        scaling_adjustment = 1
        metric_interval_lower_bound = 1
         }
    count = "${length(var.instance_suffix)}"
}
## Autoscale Alarm Metrics
resource "aws_cloudwatch_metric_alarm" "metric_alarm_cpu_high_softserve" {
  alarm_name          = "metric_alarm_high_cpu_softserve_${var.instance_suffix[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "79"

  dimensions {
    AutoScalingGroupName = "${element(aws_autoscaling_group.asg-softserve.*.name, count.index)}"
  }

  alarm_description = "This metric monitors softserve group cpu utilization"
  alarm_actions     = ["${element(aws_autoscaling_policy.scale_in_softserve.*.arn, count.index)}"]

    count = "${length(var.instance_suffix)}"
}
resource "aws_autoscaling_policy" "scale_out_softserve" {
       name                   = "autoscale_out_policy_softserve-${var.instance_suffix[count.index]}"
       adjustment_type        = "ChangeInCapacity"
       policy_type            = "StepScaling"
       estimated_instance_warmup = 35
       autoscaling_group_name = "${element(aws_autoscaling_group.asg-softserve.*.name, count.index)}"

       step_adjustment {
       scaling_adjustment = -1  # remove one node
#        scaling_adjustment = 0   # disable downscale
         metric_interval_upper_bound = 1
         }

        step_adjustment {
        scaling_adjustment = 0
        metric_interval_lower_bound = 1
         }
     count = "${length(var.instance_suffix)}"
}


resource "aws_cloudwatch_metric_alarm" "metric_alarm_cpu_low_softserve" {
  alarm_name          = "metric_alarm_low_cpu_softserve_${var.instance_suffix[count.index]}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "39"

  dimensions {
    AutoScalingGroupName = "${element(aws_autoscaling_group.asg-softserve.*.name, count.index)}"
  }

  alarm_description = "This metric monitors softserve group cpu utilization"
  alarm_actions     = ["${element(aws_autoscaling_policy.scale_out_softserve.*.arn, count.index)}"]

    count = "${length(var.instance_suffix)}"

}

## Print Output

output "softserve_elb_dns_name" {
  value = "${module.m-elb-softserve.elb_dns_name}"
}

