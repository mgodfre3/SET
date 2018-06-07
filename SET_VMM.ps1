
#Logical  Network 
$logicalNetwork = New-SCLogicalNetwork -Name "Demo1234" -LogicalNetworkDefinitionIsolation $true -EnableNetworkVirtualization $false -UseGRE $false -IsPVLAN $false
$logicalNetworkDefinition=Get-SCLogicalNetworkDefinition -LogicalNetwork $logicalNetwork
$allHostGroups = @()
$allHostGroups += Get-SCVMHostGroup -Name 'Orlando'
$allSubnetVlan = @()
$allSubnetVlan += New-SCSubnetVLan -Subnet "192.168.12.0/29" -VLanID 12
$allSubnetVlan += New-SCSubnetVLan -Subnet "192.168.11.0/29" -VLanID 11
$allSubnetVlan += New-SCSubnetVLan -Subnet "192.168.10.0/28" -VLanID 10

New-SCLogicalNetworkDefinition -Name "Demo1234_Orlando" -LogicalNetwork $logicalNetwork -VMHostGroup $allHostGroups -SubnetVLan $allSubnetVlan -RunAsynchronously


#Port Profile

$definition = @()
$definition += Get-SCLogicalNetworkDefinition -Name (Get-SCLogicalNetworkDefinition -LogicalNetwork $logicalNetwork.Name) 
New-SCNativeUplinkPortProfile -Name "Uplink-Demo1234" -Description "" -LogicalNetworkDefinition $definition -EnableNetworkVirtualization $false -LBFOLoadBalancingAlgorithm "HostDefault" -LBFOTeamMode "SwitchIndependent" -RunAsynchronously


#VMNetworks

#MGMT

$vmNetwork = New-SCVMNetwork -Name "Demo1234-MGMT" -LogicalNetwork $logicalNetwork -IsolationType "VLANNetwork"
Write-Output $vmNetwork
# Get Logical Network Definition 'Demo1234_Orlando'
$subnetVLANs = @()
$subnetVLANv4 = New-SCSubnetVLan -Subnet "192.168.10.0/28" -VLanID 10
$subnetVLANs += $subnetVLANv4
$vmSubnet = New-SCVMSubnet -Name "Demo1234-MGMT" -LogicalNetworkDefinition $logicalNetworkDefinition -SubnetVLan $subnetVLANs -VMNetwork $vmNetwork

#Cluster
$vmNetworkCL = New-SCVMNetwork -Name "Demo1234-Cluster" -LogicalNetwork $logicalNetwork -IsolationType "VLANNetwork"
Write-Output $vmNetwork
# Get Logical Network Definition 'Demo1234_Orlando'
$subnetVLANsCL = @()
$subnetVLANv4CL = New-SCSubnetVLan -Subnet "192.168.11.0/29" -VLanID 11
$subnetVLANsCL += $subnetVLANv4CL
$vmSubnetCL = New-SCVMSubnet -Name "Demo1234-Cluster" -LogicalNetworkDefinition $logicalNetworkDefinition -SubnetVLan $subnetVLANsCL -VMNetwork $vmNetworkCL

#Cluster IP Pool
# Network Routes
$allNetworkRoutesCL = @()

# Gateways
$allGatewaysCL = @()

# DNS servers
$allDnsServerCL = @()

# DNS suffixes
$allDnsSuffixesCL = @()

# WINS servers
$allWinsServersCL = @()

New-SCStaticIPAddressPool -Name "Demo1234-Cluster" -LogicalNetworkDefinition $logicalNetworkDefinition -Subnet "192.168.11.0/29" -IPAddressRangeStart "192.168.11.2" -IPAddressRangeEnd "192.168.11.6" -DefaultGateway $allGatewaysCL -DNSServer $allDnsServerCL -DNSSuffix "" -DNSSearchSuffix $allDnsSuffixesCL -NetworkRoute $allNetworkRoutesCL -RunAsynchronously


#LiveMigration
$vmNetworkLM = New-SCVMNetwork -Name "Demo1234-LM" -LogicalNetwork $logicalNetwork -IsolationType "VLANNetwork"
Write-Output $vmNetworkLM
# Get Logical Network Definition 'Demo1234_Orlando'
$subnetVLANsLM = @()
$subnetVLANv4LM = New-SCSubnetVLan -Subnet "192.168.12.0/29" -VLanID 12
$subnetVLANsLM += $subnetVLANv4LM
$vmSubnetLM = New-SCVMSubnet -Name "Demo1234-LM" -LogicalNetworkDefinition $logicalNetworkDefinition -SubnetVLan $subnetVLANsLM -VMNetwork $vmNetworkLM

#LiveMigration IP Pool

# Network Routes
$allNetworkRoutesLM = @()

# Gateways
$allGatewaysLM = @()

# DNS servers
$allDnsServerLM = @()

# DNS suffixes
$allDnsSuffixesLM = @()

# WINS servers
$allWinsServersLM = @()

New-SCStaticIPAddressPool -Name "Demo1234-LM" -LogicalNetworkDefinition $logicalNetworkDefinition -Subnet "192.168.12.0/29" -IPAddressRangeStart "192.168.12.2" -IPAddressRangeEnd "192.168.12.6" -DefaultGateway $allGatewaysLM -DNSServer $allDnsServerLM -DNSSuffix "" -DNSSearchSuffix $allDnsSuffixesLM -NetworkRoute $allNetworkRoutesLM -RunAsynchronously
 


 #logical Switch
 $logicalSwitch = New-SCLogicalSwitch -Name "Demo-1234" -Description "" -EnableSriov $false -SwitchUplinkMode "NoTeam" -MinimumBandwidthMode "Weight"

# Get Network Port Classification 'Host management'
$portClassification = Get-SCPortClassification -Name 'Host management' 

# Get Hyper-V Switch Port Profile 'Host management'
$nativeProfile = Get-SCVirtualNetworkAdapterNativePortProfile -Name 'Host Management'
New-SCVirtualNetworkAdapterPortProfileSet -Name "Host management" -PortClassification $portClassification -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfile


# Get Network Port Classification 'Host Cluster Workload'
$portClassificationCL = Get-SCPortClassification -Name 'Host Cluster Workload'
# Get Hyper-V Switch Port Profile 'Cluster'
$nativeProfileCL = Get-SCVirtualNetworkAdapterNativePortProfile -Name 'Cluster'
New-SCVirtualNetworkAdapterPortProfileSet -Name "Host Cluster Workload" -PortClassification $portClassificationCL -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfileCL 



# Get Network Port Classification 'Live migration  workload'
$portClassificationLM =  Get-SCPortClassification -Name 'Live migration  workload'
# Get Hyper-V Switch Port Profile 'Live migration'
$nativeProfileLM = Get-SCVirtualNetworkAdapterNativePortProfile -Name 'Live migration'
New-SCVirtualNetworkAdapterPortProfileSet -Name "Live migration  workload" -PortClassification $portClassificationLM -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfileLM


# Get Network Port Classification 'High bandwidth'
$portClassificationHB = Get-SCPortClassification -Name 'High bandwidth'
# Get Hyper-V Switch Port Profile 'High Bandwidth Adapter'
$nativeProfileHB = Get-SCVirtualNetworkAdapterNativePortProfile -name 'High Bandwidth Adapter'
New-SCVirtualNetworkAdapterPortProfileSet -Name "High bandwidth" -PortClassification $portClassificationHB -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfileHB


# Get Network Port Classification 'Low bandwidth'
$portClassificationLB = Get-SCPortClassification -Name 'Low bandwidth'
# Get Hyper-V Switch Port Profile 'Low Bandwidth Adapter'
$nativeProfileLB = Get-SCVirtualNetworkAdapterNativePortProfile -name 'Low Bandwidth Adapter'
New-SCVirtualNetworkAdapterPortProfileSet -Name "Low bandwidth" -PortClassification $portClassificationLB -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfileLB

# Get Network Port Classification 'Medium bandwidth'
$portClassificationMB = Get-SCPortClassification -Name 'Medium bandwidth'
# Get Hyper-V Switch Port Profile 'Medium Bandwidth Adapter'
$nativeProfileMB = Get-SCVirtualNetworkAdapterNativePortProfile -name 'Medium Bandwidth Adapter'
New-SCVirtualNetworkAdapterPortProfileSet -Name "Medium bandwidth" -PortClassification $portClassificationMB -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfileMB

# Get Native Uplink Port Profile 'Uplink-Demo1234'
$nativeUppVar = Get-SCNativeUplinkPortProfile -Name 'Uplink-Demo1234'
$uppSetVar = New-SCUplinkPortProfileSet -Name "Uplink-Demo1234" -LogicalSwitch $logicalSwitch -NativeUplinkPortProfile $nativeUppVar -RunAsynchronously


# Get VM Network 'Demo1234-Cluster'
$vmNetworkCl = Get-SCVMNetwork -Name 'Demo1234-Cluster'

# Get VMSubnet 'Demo1234-Cluster'
$vmSubnetCL = Get-SCVMSubnet -Name 'Demo1234-Cluster'

# Get Network Port Classification 'Host Cluster Workload'
$vNICPortClassificationCL = Get-SCPortClassification -name 'Host Cluster Workload'

# Get Static IP Address Pool 'Demo1234-Cluster'
$ipV4PoolCL = Get-SCStaticIPAddressPool -Name 'Demo1234-Cluster'
New-SCLogicalSwitchVirtualNetworkAdapter -Name "Cluster" -UplinkPortProfileSet $uppSetVar -RunAsynchronously -VMNetwork $vmNetworkCL -VMSubnet $vmSubnetCL -PortClassification $vNICPortClassificationCL -IsUsedForHostManagement $false -IPv4AddressType "Static" -IPv6AddressType "Dynamic" -IPv4AddressPool $ipV4PoolCL


# Get VM Network 'Demo1234-LM'
$vmNetworkLM = Get-SCVMNetwork -Name 'Demo1234-LM'

# Get VMSubnet 'Demo1234-LM'
$vmSubnetLM = Get-SCVMSubnet -Name 'Demo1234-LM'

# Get Network Port Classification 'Live migration  workload'
$vNICPortClassificationLM = Get-SCPortClassification -Name 'Live migration  workload'

# Get Static IP Address Pool 'Demo1234-LM'
$ipV4PoolLM = Get-SCStaticIPAddressPool -Name 'Demo1234-LM'
New-SCLogicalSwitchVirtualNetworkAdapter -Name "LiveMigration" -UplinkPortProfileSet $uppSetVar -RunAsynchronously -VMNetwork $vmNetworkLM -VMSubnet $vmSubnetLM -PortClassification $vNICPortClassificationLM -IsUsedForHostManagement $false -IPv4AddressType "Static" -IPv6AddressType "Dynamic" -IPv4AddressPool $ipV4PoolLM




# Get VM Network 'Demo1234-MGMT'
$vmNetworkMGMT = Get-SCVMNetwork -name 'Demo1234-MGMT'

# Get VMSubnet 'Demo1234-MGMT'
$vmSubnetMGMT = Get-SCVMSubnet -Name 'Demo1234-MGMT'

# Get Network Port Classification 'Host management'
$vNICPortClassificationMGMT = Get-SCPortClassification -Name 'Host Managment'
New-SCLogicalSwitchVirtualNetworkAdapter -Name "MGMT" -UplinkPortProfileSet $uppSetVar -RunAsynchronously -VMNetwork $vmNetworkMGMT  -VMSubnet $vmSubnetMGMT -PortClassification $vNICPortClassificationMGMT -IsUsedForHostManagement $true -InheritsAddressFromPhysicalNetworkAdapter $true -IPv4AddressType "Dynamic" -IPv6AddressType "Dynamic"
