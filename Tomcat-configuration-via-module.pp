pdk new module tomcat --skip-interview
pdk new module java --skip-interview

#inside java module manifest/install.pp
class java::install { 
   package { [ 'epel-release-7-11.noarch', 'java-1.7.0-openjdk'] : 
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

# /etc/puppetlabs/code/environments/production/modules/tomcat/install.pp
class tomcat::install {   
    
    package { [ 'tomcat', 'tomcat-webapps' ]: 
       ensure => installed, 
       require => Package['epel-release-7-11.noarch']
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

# inside /etc/puppetlabs/code/environments/production/modules/tomcat/service.pp
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

