#escape=\

FROM mcr.microsoft.com/windows/servercore:1809

# set default args
ARG VERSIONNANO=1809
ARG VERSIONJENKINS=latest
ARG OpenJDK=17.0.8.1

# Set Jenkins options
ENV JENKINS_OPTS="--httpPort=-1 --httpsPort=8443 --httpsKeyStore=C:/jenkins_home/keystore.jks --httpsKeyStorePassword=changeit"

# Set Java options
ENV JAVA_OPTS="-Djavax.net.ssl.keyStore=C:/jenkins_home/keystore.jks -Djavax.net.ssl.keyStorePassword=changeit -Djavax.net.ssl.trustStore=C:/jenkins_home/keystore.jks -Djavax.net.ssl.trustStorePassword=changeit"

# Download jenkins.war
ADD http://mirrors.jenkins.io/war-stable/$VERSIONJENKINS/jenkins.war C:/install/jenkins.war
RUN powershell -Command Get-ChildItem -Path C:/install

# Download OpenJDK and install
ADD https://aka.ms/download-jdk/microsoft-jdk-$OpenJDK-windows-x64.msi C:/install/openJDK.msi
RUN powershell -Command Start-Process -Wait -FilePath msiexec -ArgumentList '/i', 'C:\install\openJDK.msi', 'ADDLOCAL="FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome"', 'INSTALLDIR="C:\openJDK"', '/quiet'

# Copy and configure Jenkins
RUN powershell -Command " \
    New-Item -ItemType Directory -Path C:/jenkins_home ; \
    Copy-Item -Path C:/install/jenkins.war -Destination C:/jenkins_home/jenkins.war ; \
    Set-Item -Path Env:JENKINS_HOME -Value C:/jenkins_home ; \
    Get-ChildItem -Path C:/jenkins_home \
"

# COPY C:/install/jenkins.war C:/jenkins_home/jenkins.war
# RUN powershell -Command Get-ChildItem -Path C:/jenkins_home

# Generate a self-signed certificate and add it to the Java keystore
RUN powershell -Command " \
    $cert = New-SelfSignedCertificate -DnsName 'localhost' -CertStoreLocation Cert:\LocalMachine\My ; \
    Export-Certificate -Cert $cert -FilePath C:/jenkins_home/cert.pem ; \
    Export-PfxCertificate -Cert $cert -FilePath C:/jenkins_home/key.pem -Password (ConvertTo-SecureString -String 'your-password' -Force -AsPlainText) ; \
    & 'C:/openJDK/bin/keytool.exe' -genkey -alias localhost -keyalg RSA -keystore 'C:/jenkins_home/keystore.jks' -storepass 'changeit' -keypass 'changeit' -dname 'CN=localhost, OU=Test, O=Test, L=Test, ST=Test, C=US' ; \
    & 'C:/openJDK/bin/keytool.exe' -import -alias localhost -keystore 'C:/openJDK/lib/security/cacerts' -file 'C:/jenkins_home/cert.pem' -storepass 'changeit' -noprompt \
"

# Copy script to unlock Jenkins configuration
# COPY Unlock-Jenkins.ps1 C:/Scripts/Unlock-Jenkins.ps1
# RUN powershell -ExecutionPolicy Bypass -File C:/Unlock-Jenkins.ps1
RUN powershell -Command New-Item -ItemType Directory -Path C:/Scripts ; \ 
    Get-ChildItem -Path C:/Scripts ; \
    Get-ChildItem -Path C:/jenkins_home

# Copy script to unlock Jenkins configuration
COPY Unlock-Jenkins.ps1 C:/Scripts/Unlock-Jenkins.ps1
RUN powershell -Command Get-ChildItem -Path C:/Scripts

# bootstrap jenkins at startup
CMD C:/openJDK/bin/java.exe -jar C:/jenkins_home/jenkins.war %JENKINS_OPTS%
# CMD ["C:/openJDK/bin/java.exe", "-jar", "C:/jenkins_home/jenkins.war", "%JENKINS_OPTS%"]
# CMD ["C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "C:/Scripts/Unlock-Jenkins.ps1"]
# CMD "powershell -ExecutionPolicy Bypass -File C:/Scripts/Unlock-Jenkins.ps1"
# CMD "powershell -ExecutionPolicy Bypass -File C:/Scripts/Unlock-Jenkins.ps1"



# Copy script to create admin account
COPY 1-setup.groovy C:/jenkins_home/init.groovy.d/1-setup.groovy

# Copy script to perform initial setup and install plugins
COPY 2-install-plugins.groovy C:/jenkins_home/init.groovy.d/2-install-plugins.groovy
ENV JENKINS_PLUGINS workflow-aggregator,git,credentials-binding

# Copy Java and configure environment variables
ENV JAVA_HOME C:/openJDK
ENV JAVA_VERSION ${OpenJDK}
ENV CLASSPATH C:/openJDK/lib
ENV JAVA_TOOL_OPTIONS -Djava.awt.headless=true
# ENV PATH C:/openJDK/bin;C:/Windows/system32;C:/Windows;
ENV PATH=${PATH};C:/openJDK/bin;C:/Windows/system32;C:/Windows;

# LABEL and EXPOSE to document runtime settings
ENV JENKINS_HOME C:/jenkins_home
VOLUME C:/jenkins_storage
EXPOSE 8443/tcp
LABEL maintainer="eric@codeholics.com"
LABEL description="Jenkins for Windows"

# CD D:\
# CD "D:\Code\Repos\Docker\jenkins-windowsselfsigned"
# docker build -t jenkins-windows2:latest .
# docker run -p 8443:8443 --name jenkins-windows2 jenkins-windows2:latest

# docker commit youthful_lamport my-jenkins-image:latest

# Copy script to C:/Storage
# COPY Unlock-Jenkins.ps1 C:/Storage/Unlock-Jenkins.ps1
#docker exec -it jenkins-windows2 powershell -ExecutionPolicy Bypass -File C:/Storage/Unlock-Jenkins.ps1