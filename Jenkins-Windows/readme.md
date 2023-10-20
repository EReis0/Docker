# Docker: Jenkins for Windows

I will add more context here shortly, but I created this to be used as a dev instance for Jenkins to test updates and new features before deploying to production. 

Here are some of the features:

- Windows server core
- OpenJDK 17 installed via MSI
- LetsEncryptCert with KeyStore configuration
- Download Jenkins War file
- Initial Jenkins install
- User control of final Jenkins configuration via web UI. `localhost:8080`

## Requirements

- Docker for windows (not tested with a Linux host)