# Retrieve the initial admin password from the console
$adminPassword = Get-Content "C:\Users\ContainerAdministrator\.jenkins\secrets\initialAdminPassword" | Out-String

# Generate the auto install configuration with the initial admin password
$autoInstallConfig = @"
<jenkins>
  <install plugin="workflow-aggregator@latest" />
  <install plugin="git@latest" />
  <install plugin="credentials-binding@latest" />
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
    <users>
      <hudson.model.User>
        <id>admin</id>
        <fullName>Administrator</fullName>
        <passwordHash>$adminPassword</passwordHash>
      </hudson.model.User>
    </users>
  </securityRealm>
  <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy" />
  <disableRememberMe>false</disableRememberMe>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar" />
  <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar" />
  <clouds />
  <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" />
      <name>all</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList" />
    </hudson.model.AllView>
  </views>
  <primaryView>all</primaryView>
  <slaveAgentPort>-1</slaveAgentPort>
  <disabledAgentProtocols>
    <string>JNLP-connect</string>
    <string>JNLP2-connect</string>
  </disabledAgentProtocols>
  <remotingSecurityEnabled>true</remotingSecurityEnabled>
  <crumbIssuer class="hudson.security.csrf.DefaultCrumbIssuer">
    <excludeClientIPFromCrumb>false</excludeClientIPFromCrumb>
  </crumbIssuer>
</jenkins>
"@