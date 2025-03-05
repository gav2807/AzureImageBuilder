@allowed([
  'np01'
  'pr01'
])
param environment string
param name string = 'ubuntu-pro-2204'
param location string = 'uksouth'
param version string

targetScope = 'subscription'

var computeGalleryName = 'sbsuks${environment}cmnsvcimagegal'
var templateName = 'sbs-uks-${environment}-ubuntu-pro-2204-it'

resource resouceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: 'sbs-uks-${environment}-cmnsvc-gallery-rg'
}

resource imageBuilderRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'sbs-uks-${environment}-cmnsvc-aib-${name}-rg'
  location: location
}

module imageDefinition '../modules/imageDefinition.bicep' = {
  name: '${uniqueString(deployment().name)}-imageDefinition'
  scope: resouceGroup
  params: {
    computeGalleryName: computeGalleryName
    imageDefinition: {
      name: 'ubuntupro2204'
      sku: 'sbs-ubuntu-pro-2204'
      publisher: 'skipton-building-society'
      offer: templateName
      osType: 'Linux'
    }
    location: resouceGroup.location
  }
}

module imageTemplate '../modules/imageTemplate.bicep' = {
  name: '${uniqueString(deployment().name)}-imageTemplate'
  scope: resouceGroup
  params: {
    osName: name
    computeGalleryName: computeGalleryName
    customizers: [
      {
        type: 'Shell'
        name: 'installTooling'
        inline: [
          'sleep 60'
        ]
      }
      {
        type: 'Shell'
        name: 'installNode'
        inline: [
          'sudo apt update -y'
          'sudo apt install curl -y'
          'sudo curl -fsSL https://deb.nodesource.com/setup_23.x | sudo -E bash -'
          'sudo apt-get install nodejs -y'
        ]
      }
      {
        type: 'Shell'
        name: 'installTooling'
        inline: [
          'sudo apt-get update -y'
          'sudo apt-get install ubuntu-advantage-tools docker.io ca-certificates unattended-upgrades curl jq zip unzip tzdata wget git apt-transport-https lsb-release gnupg software-properties-common libssl-dev dotnet-sdk-8.0 dotnet-runtime-8.0 -y'
          'sudo ua enable usg'
          'sudo apt install usg -y'
        ]
      }
      {
        type: 'Shell'
        name: 'powershell'
        inline: [
          'sudo apt-get update'
          'sudo apt-get install -y wget apt-transport-https software-properties-common'
          'wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb'
          'sudo dpkg -i packages-microsoft-prod.deb'
          'sudo apt-get update'
          'sudo apt-get install -y powershell'
          'rm packages-microsoft-prod.deb'
        ]
      }
      {
        type: 'Shell'
        name: 'installAzCli'
        inline: [
          'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
        ]
      }
      {
        type: 'Shell'
        name: 'InstallKubectl'
        inline: [
          'az aks install-cli'
        ]
      }
      {
        type: 'Shell'
        name: 'InstallHelm'
        inline: [
          'curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3'
          'sudo chmod 700 get_helm.sh'
          './get_helm.sh'
        ]
      }
      {
        type: 'Shell'
        name: 'createAdoUser'
        inline: [
          'sudo useradd -m AzDevOps'
          'sudo usermod -aG docker AzDevOps'
        ]
      }
      {
        type: 'Shell'
        name: 'customCISProfile'
        inline: [
          'sudo usg generate-tailoring cis_level1_server tailor.xml'
        ]
      }
      {
        type: 'Shell'
        name: 'ExcludeCISRules'
        inline: [
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_nftables_ensure_default_deny_policy" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_nftables_ensure_default_deny_policy" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_sshd_limit_user_access" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_sshd_limit_user_access" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_grub2_password" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_grub2_password" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_permissions_local_var_log" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_permissions_local_var_log" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_accounts_password_last_change_is_in_past" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_accounts_password_last_change_is_in_past" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_ensure_root_password_configured" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_ensure_root_password_configured" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_partition_for_tmp" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_partition_for_tmp" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_package_chrony_installed" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_package_chrony_installed" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_package_ntp_installed" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_package_ntp_installed" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_package_ufw_installed" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_package_ufw_installed" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_package_iptables-persistent_installed" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_package_iptables-persistent_installed" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_service_nftables_disabled" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_service_nftables_disabled" selected="false"/>,g\' tailor.xml'
          'sudo sed -i \'s,<select idref="xccdf_org.ssgproject.content_rule_package_nftables_removed" selected="true"/>,<select idref="xccdf_org.ssgproject.content_rule_package_nftables_removed" selected="false"/>,g\' tailor.xml'
        ]
      }
      {
        type: 'Shell'
        name: 'enableCISHardening'
        inline: [
          'sudo usg fix --tailoring-file tailor.xml || true'
        ]
      }
      {
        type: 'Shell'
        name: 'auditCISHardening'
        inline: [
          'usg audit --tailoring-file tailor.xml'
        ]
      }
      {
        type: 'Shell'
        name: 'enableIpv4Forwarding'
        inline: [
          'echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.d/enabled_ipv4_forwarding.conf'
        ]
      }
      {
        type: 'Shell'
        name: 'DetachUA -- images created from this will auto attach themselves with new credentials'
        inline: [
            'sudo ua detach --assume-yes && sudo rm -rf /var/log/ubuntu-advantage.log'
        ]
      }
    ]
    environment: environment
    imageDefinitionName: imageDefinition.outputs.properties.name
    imageTemplateName: templateName
    image: {
      sku: 'pro-22_04-lts'
      offer: '0001-com-ubuntu-pro-jammy'
      publisher: 'canonical'
      version: 'latest'
      planInfo: {
        planName: 'pro-22_04-lts'
        planProduct: '0001-com-ubuntu-pro-jammy'
        planPublisher: 'canonical'
      }
    }
    location: resouceGroup.location
    version: version
  }
}
