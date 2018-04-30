name 'wayneweb'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures wayneweb'
long_description 'Installs/Configures wayneweb'
version '0.2.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

#depends 'yum-scl'
#depends 'yum-epel'
depends 'yum'


# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/wayneweb/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/wayneweb'
