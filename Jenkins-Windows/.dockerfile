#escape=\

FROM mcr.microsoft.com/windows/servercore:1809

# set default args
ARG VERSIONNANO=1809
ARG VERSIONJENKINS=latest
ARG OpenJDK=17.0.8.1

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
    New-Item -ItemType Directory -Path C:/jenkins ; \
    Copy-Item -Path C:/install/jenkins.war -Destination C:/jenkins/jenkins.war ; \
    Set-Item -Path Env:JENKINS_HOME -Value C:/jenkins_home

# bootstrap jenkins at startup
CMD C:/openJDK/bin/java.exe -jar C:/jenkins/jenkins.war

# Copy Java and configure environment variables
ENV JAVA_HOME C:/openJDK
ENV JAVA_VERSION ${OpenJDK}
ENV CLASSPATH C:/openJDK/lib
ENV JAVA_TOOL_OPTIONS -Djava.awt.headless=true
ENV PATH C:/openJDK/bin;C:/Windows/system32;C:/Windows;

# LABEL and EXPOSE to document runtime settings
VOLUME C:/jenkins_home
EXPOSE 8080/tcp
LABEL maintainer="eric@codeholics.com"
LABEL description="Jenkins for Windows"

# docker build -t JenkinsW-image -f D:\Code\Docker\Jenkins-Windows\.dockerfile D:\Code\Docker\Jenkins-Windows
# docker run -p 8080:8080 JenkinsW-image