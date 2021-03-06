name "nadder-01"
description "Master role applied to nadder-01"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "192.163.219.36",
        :prefix => "19",
        :gateway => "192.163.192.1"
      }
    }
  },
  :sysctl => {
    :kvm => {
      :comment => "Tuning for KVM guest",
      :parameters => { 
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000
      }
    }
  },
  :sysfs => {
    :hdd_tune => {
      :comment => "Tune the queue for improved performance",
      :parameters => {
        "block/vda/queue/nr_requests" => "128",
        "block/vdb/queue/nr_requests" => "128",
        "block/vda/queue/scheduler" => "deadline",
        "block/vdb/queue/scheduler" => "deadline"
      }
    }
  },
  :squid => {
    :cache_mem => "6500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "provo.render.openstreetmap.org",
    :tile_siblings => [
      "nadder-02.openstreetmap.org",
      "jakelong.openstreetmap.org",
      "nepomuk.openstreetmap.org",
      "lurien.openstreetmap.org"
    ]
  }
)

run_list(
  "role[bluehost]",
  "role[tilecache]"
)
