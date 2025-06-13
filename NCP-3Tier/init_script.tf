resource "ncloud_init_script" "init" {
  name    = "ls-script"
  content = "#!/usr/bin/env\nls -al"
}