name "ascalon"
description "Master role applied to ascalon"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.18"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.105"
      }
    }
  }
)

run_list(
  "role[ucl-internal]"
)