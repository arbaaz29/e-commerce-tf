//wait for the instnaces to be configured fully
resource "time_sleep" "wait_3_minutes" {
  depends_on = [ aws_instance.webserver ]
  create_duration = "150s"
}
