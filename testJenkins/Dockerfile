#escape=\

FROM mcr.microsoft.com/windows/servercore:1809

# set default args
ARG VERSIONNANO=1809
ARG VERSIONJENKINS=latest
ARG OpenJDK=17.0.8.1

ENV JENKINS_OPTS="--httpsPort=8443 --httpsCertificate=C:/jenkins_home/cert.pem --httpsPrivateKey=C:/jenkins_home/key.pem"

# Download jenkins.war
ADD http://mirrors.jenkins.io/war-stable/$VERSIONJENKINS/jenkins.war C:/install/jenkins.war

# Download OpenJDK and install
ADD https://aka.ms/download-jdk/microsoft-jdk-$OpenJDK-windows-x64.msi C:/install/openJDK.msi
RUN powershell -Command Start-Process -Wait -FilePath msiexec -ArgumentList '/i', 'C:\install\openJDK.msi', 'ADDLOCAL="FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome"', 'INSTALLDIR="C:\openJDK"', '/quiet'
#RUN msiexec /i C:/install/openJDK.msi /quiet /qn /norestart INSTALLDIR=c:/openJDK /L*V /L install64.log

# Add LetsEncrypt root/inter certificates into openJDK cert trust so Jenkins can download extensions reliably
ADD https://letsencrypt.org/certs/isrgrootx1.pem.txt C:/install/letsencryptroot.crt
ADD https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt C:/install/letsencryptauthorityx3a.crt
ADD https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt C:/install/letsencryptauthorityx3b.crt
ADD https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.pem.txt C:/install/letsencryptauthorityx4a.crt
ADD https://letsencrypt.org/certs/letsencryptauthorityx4.pem.txt C:/install/letsencryptauthorityx4b.crt
RUN C:/openJDK/bin/keytool -import -alias letsencryptroot -keystore C:/openJDK/lib/security/cacerts -storepass changeit -file C:/install/letsencryptroot.crt -noprompt
RUN C:/openJDK/bin/keytool -import -alias letsencryptauthorityx3a -keystore C:/openJDK/lib/security/cacerts -storepass changeit -file C:/install/letsencryptauthorityx3a.crt -noprompt
RUN C:/openJDK/bin/keytool -import -alias letsencryptauthorityx3b -keystore C:/openJDK/lib/security/cacerts -storepass changeit -file C:/install/letsencryptauthorityx3b.crt -noprompt
RUN C:/openJDK/bin/keytool -import -alias letsencryptauthorityx4a -keystore C:/openJDK/lib/security/cacerts -storepass changeit -file C:/install/letsencryptauthorityx4a.crt -noprompt
RUN C:/openJDK/bin/keytool -import -alias letsencryptauthorityx4b -keystore C:/openJDK/lib/security/cacerts -storepass changeit -file C:/install/letsencryptauthorityx4b.crt -noprompt

# Copy and configure Jenkins
RUN powershell -Command \
    New-Item -ItemType Directory -Path C:/jenkins_home ; \
    Copy-Item -Path C:/install/jenkins.war -Destination C:/jenkins_home/jenkins.war ; \
    Set-Item -Path Env:JENKINS_HOME -Value C:/jenkins_home

# Copy script to unlock Jenkins configuration
COPY Unlock-Jenkins.ps1 C:/Unlock-Jenkins.ps1
RUN powershell -ExecutionPolicy Bypass -File C:/Unlock-Jenkins.ps1

# Copy script to create admin account
COPY 1-setup.groovy C:/jenkins_home/init.groovy.d/1-setup.groovy

# Copy script to perform initial setup and install plugins
COPY 2-install-plugins.groovy C:/jenkins_home/init.groovy.d/2-install-plugins.groovy
ENV JENKINS_PLUGINS workflow-aggregator,git,credentials-binding

# bootstrap jenkins at startup
# CMD C:/openJDK/bin/java.exe -jar C:/jenkins/jenkins.war
CMD C:/openJDK/bin/java.exe -jar C:/jenkins_home/jenkins.war --httpsPort=8443 --httpsCertificate=C:/jenkins_home/cert.pem --httpsPrivateKey=C:/jenkins_home/key.pem

# Copy Java and configure environment variables
ENV JAVA_HOME C:/openJDK
ENV JAVA_VERSION ${OpenJDK}
ENV CLASSPATH C:/openJDK/lib
ENV JAVA_TOOL_OPTIONS -Djava.awt.headless=true
ENV PATH C:/openJDK/bin;C:/Windows/system32;C:/Windows;

# LABEL and EXPOSE to document runtime settings
ENV JENKINS_HOME C:/jenkins_home
VOLUME C:/jenkins_home
EXPOSE 8443/tcp
LABEL maintainer="eric@codeholics.com"
LABEL description="Jenkins for Windows"

# Enable SSL Jenkins (linux)
# COPY https.pem /var/lib/jenkins/cert
# COPY https.key /var/lib/jenkins/pk
# ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsCertificate=/var/lib/jenkins/cert --httpsPrivateKey=/var/lib/jenkins/pk --httpsCertificate --httpsPrivateKey
# EXPOSE 8083

# CD D:\
# CD "D:\Code\Repos\Docker\testJenkins\"
# docker build -t jenkins-windows2:latest .
# docker run -p 8443:8443 --name jenkins-windows2 jenkins-windows2:latest

# docker commit youthful_lamport my-jenkins-image:latest

## run jenkins so it can pull the admin password and update the jenkins config. 
# docker run -p 8080:8080 -v jenkins_home:C:/jenkins_home jenkins-windows2:latest powershell -Command "echo `$autoInstallConfig | Out-File -Encoding utf8 C:/jenkins/jenkins.install.InstallUtil.xml ; C:/openJDK/bin/java.exe -jar C:/jenkins/jenkins.war"