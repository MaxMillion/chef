name "thorn-02"
description "Master role applied to thorn-02"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.166"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[web-backend]"
)
