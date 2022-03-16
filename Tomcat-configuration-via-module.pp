pdk new module tomcat --skip-interview
pdk new module java --skip-interview

#inside /etc/puppetlabs/code/environments/production/modules/java/manifests/install.pp
class java::install { 
   package { [ 'epel-release', 'java-1.7.0-openjdk'] : 
     ensure => installed,
  }
}
#inside /etc/puppetlabs/code/environments/production/manifests/app.pp

node 'puppetagent01.example.com' {
   notify{"*************node1-segment***************":} 
   include java::install
   #include tomcat::install
   #include tomcat::config
   #include tomcat::service
}
puppet agent -t

# /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/install.pp
class tomcat::install {   
    
    package { [ 'tomcat', 'tomcat-webapps' ]: 
       ensure => installed, 
       require => Package['epel-release']
    } 
}

#inside /etc/puppetlabs/code/environments/production/manifests/app.pp

node 'puppetagent01.example.com' {
   notify{"*************node1-segment***************":} 
   include java::install
   include tomcat::install
   #include tomcat::config
   #include tomcat::service
}

puppet agent -t

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifest/service.pp
class tomcat::service { 
  service { "tomcat": 
   ensure => running, 
     enable => true,
  }
}

#inside /etc/puppetlabs/code/environments/production/manifests/app.pp
node 'puppetagent01.example.com' {
   notify{"*************node1-segment***************":} 
   include java::install
   include tomcat::install
   #include tomcat::config
   include tomcat::service
}

puppet agent -t

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/files/tomcat.conf

TOMCAT_CFG_LOADED="1"
                                                                                                                                
JAVA_HOME="/usr/lib/jvm/jre" 
JAVA_OPTS="-Xms64m -Xmx128m -XX:MaxPermSize=128M -Djava.security.egd=file:/dev/./urandom"
                                                                                                                                
CATALINA_BASE="/usr/share/tomcat" 
CATALINA_HOME="/usr/share/tomcat" 
JASPER_HOME="/usr/share/tomcat" 
CATALINA_TMPDIR="/var/cache/tomcat/temp"
                                                                                                                                
                                                                                                                                
TOMCAT_USER="tomcat"
                                                                                                                                
SECURITY_MANAGER="false"
                                                                                                                                
SHUTDOWN_WAIT="30"
                                                                                                                                
SHUTDOWN_VERBOSE="false"
                                                                                                                                
CATALINA_PID="/var/run/tomcat.pid"

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifest/config.pp

file { '/etc/tomcat/tomcat.conf': 
  source => 'puppet:///modules/tomcat/tomcat.conf', 
  owner => 'tomcat', 
  group => 'tomcat', 
  mode   => '0644', 
  notify => Service['tomcat']
  } 
}

#inside /etc/puppetlabs/code/environments/production/manifests/app.pp
node 'puppetagent01.example.com' {
   notify{"*************node1-segment***************":} 
   include java::install
   include tomcat::install
   include tomcat::config
   include tomcat::service
}

puppet agent -t

# create init.pp inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests
# Add below lines
class tomcat {

include tomcat::install 
include tomcat::config
include tomcat::service
include tomcat::scope
} 

#inside /etc/puppetlabs/code/environments/production/manifests/app.pp make below change
node 'puppetagent01.example.com' {
notify{"*************node1-segment***************":}
include java::install
include tomcat
}

puppet agent -t

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/params.pp

class tomcat::params{
$color = 'white'
$car = 'figo'

}

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/scope.pp
class tomcat::scope inherits tomcat::params {
$color = 'yellow-from-scope' 
notify{"print the scope":
 message => " 
    FAVOURITE COLOR : ${color} 
    FAVOURITE CAR : ${car}
 "
  }
}
# Add scope.pp into init.pp

puppet agent -t

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/params.pp

class tomcat::params {
  $color = 'white'
  $car = 'figo'
  $user = 'tomcat' 
  $group = 'tomcat' 
  $config_path = '/etc/tomcat/tomcat.conf' 
  $packages = [ 'tomcat', 'tomcat-webapps' ] 
  $service_name = 'tomcat'
  $service_state = running
}

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/install.pp

class tomcat::install inherits tomcat {
   # package { [ 'tomcat', 'tomcat-webapps' ]:
     package { $::tomcat::packages:
      ensure => installed,
      require => Package['epel-release-7-11.noarch']
    }
}

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/service.pp

/*
class tomcat::service { 
  service { "tomcat": 
   ensure => running, 
     enable => true,
  }
}
*/

class tomcat::service inherits tomcat{
 
  service { $::tomcat::service_name: 
  ensure   => $::tomcat::service_state, 
  enable   => true, 
  require  => Class['tomcat::install'],

   }
}


#inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/config.pp

/*
class tomcat::config {
 
file { '/etc/tomcat/tomcat.conf': 
  source => 'puppet:///modules/tomcat/tomcat.conf', 
  owner => 'tomcat', 
  group => 'tomcat', 
  mode   => '0644', 
  notify => Service['tomcat']
  }
}
*/


class tomcat::config inherits tomcat{

  file { $::tomcat::config_path: 
#   source => 'puppet:///modules/tomcat/tomcat.conf',
    content  => template('tomcat/tomcat.conf.erb'), 
    owner  => $::tomcat::user, 
    group  => $::tomcat::group, 
    mode   => '0644', 
    notify => Service['tomcat']
  }
}
puppet agent -t


##inside /etc/puppetlabs/code/environments/production/modules/tomcat/templates/tomcat.conf.erb

TOMCAT_CFG_LOADED=<%= @tomcat_cfg_loaded %>
                                                                                                                                
JAVA_HOME=<%= @java_home %> 
JAVA_OPTS=<%= @java_opts %>
                                                                                                                                
CATALINA_BASE=<%= @catalina_base %> 
CATALINA_HOME=<%= @catalina_home %> 
JASPER_HOME=<%= @jasper_home %> 
CATALINA_TMPDIR=<%= @catalina_tmpdir %>
                                
                                                                                                
                                                                                                                                
TOMCAT_USER=<%= @user %> 
SECURITY_MANAGER=<%= @security_manager %>
                                                                                                                                
SHUTDOWN_WAIT=<%= @shutdown_wait %> 
SHUTDOWN_VERBOSE=<%= @shutdown_verbose %>
                                                                                                                                
CATALINA_PID=<%= @catalina_pid %>

#inside /etc/puppetlabs/code/environments/production/modules/tomcat/manifests/params.pp


class tomcat::params { 
$color = 'white' 
$car = 'figo' 
$user = 'tomcat' 
$group = 'tomcat' 
$config_path = '/etc/tomcat/tomcat.conf' 
$packages = [  'tomcat', 'tomcat-webapps' ] 
$service_name = 'tomcat' 
$service_state = running 
$tomcat_cfg_loaded = "1" 
$java_home = "/usr/lib/jvm/jre" 
$xms = "64m" 
$xmx = "128m" 
$maxpermsize = "128M" 
$java_opts = "-Xms${xms} -Xmx${xmx} -XX:MaxPermSize=${maxpermsize} -Djava.security.egd=file:/dev/./urandom" 
$catalina_base = "/usr/share/tomcat" 
$catalina_home = "/usr/share/tomcat" 
$jasper_home = "/usr/share/tomcat" 
$catalina_tmpdir = "/var/cache/tomcat/temp" 
$security_manager = "false" 
$shutdown_wait = "30" 
$shutdown_verbose = "false"
$catalina_pid = "/var/run/tomcat.pid"

puppet agent -t

#check for tomcat service status.. if it is running then run below cmd
puppet agent -t

# There will not be any catlog execution.
# make some change in params.pp in regared to puppet conf.
# run below command
puppet agent -t

# you will see catlog execution due to new config file generation
# which is happening due to tomcat.conf.erb file compilation into new config file
# in dynamic way










