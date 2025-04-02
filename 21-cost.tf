# // NEED MANUAL Cost and Usage Report (CUR)

# // Anomaly Monitoring
# resource "aws_ce_anomaly_monitor" "example" {
#   name           = "example-anomaly-monitor"
#   monitor_type      = "DIMENSIONAL"
#   monitor_dimension = "SERVICE"
# }

# resource "aws_ce_anomaly_subscription" "example" {
#   name            = "example-anomaly-subscription"
#   frequency       = "DAILY"  # DAILY, WEEKLY
#   monitor_arn_list = [aws_ce_anomaly_monitor.example.arn]
  
#   subscriber {
#     type        = "EMAIL"
#     address     = "arbazij@gmail.com"
#   }

#   threshold_expression {
#     dimension {
#       key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
#       match_options = ["GREATER_THAN_OR_EQUAL"]
#       values        = ["100"]
#     }
#   }
# }



# # // NEED MANUAL Reserved Instances

# # // NEED MANUAL Savings Plans
