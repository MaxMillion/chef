name              "web"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures www.openstreetmap.org servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
depends           "apache"
depends           "passenger"
depends           "git"
depends           "memcached"
depends           "tools"
