//create ami from the webserver instances
resource "aws_ami_from_instance" "cnf_copy" {
  depends_on = [ time_sleep.wait_3_minutes ]
  name="configured_copy"
  source_instance_id = aws_instance.webserver.id
  snapshot_without_reboot = true
}