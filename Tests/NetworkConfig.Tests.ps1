#Requires -Modules Pester
BeforeAll {
    . "$PSScriptRoot\_Stubs.ps1"
    . "$PSScriptRoot\..\Private\Logging.ps1"
    . "$PSScriptRoot\..\Private\NetworkConfig.ps1"
    Mock Write-HVLog { }
}

Describe "Get-HVNetworkProfile" {
    Context "Adapter classification" {
        BeforeEach {
            Mock Get-CimInstance {
                param($ClassName)
                if ($ClassName -eq 'Win32_NetworkAdapterConfiguration') {
                    @(
                        [PSCustomObject]@{ IPEnabled=$true; Index=1; IPAddress=@('10.0.0.1'); IPSubnet=@('255.255.255.0'); MACAddress='AA:BB:CC:DD:EE:01'; Description='Management Adapter' }
                        [PSCustomObject]@{ IPEnabled=$true; Index=2; IPAddress=@('10.1.0.1'); IPSubnet=@('255.255.255.0'); MACAddress='AA:BB:CC:DD:EE:02'; Description='LiveMigration Adapter' }
                        [PSCustomObject]@{ IPEnabled=$true; Index=3; IPAddress=@('10.2.0.1'); IPSubnet=@('255.255.255.0'); MACAddress='AA:BB:CC:DD:EE:03'; Description='Storage NIC' }
                    )
                }
                elseif ($ClassName -eq 'Win32_NetworkAdapter') {
                    @(
                        [PSCustomObject]@{ Index=1; NetEnabled=$true; NetConnectionID='Management' }
                        [PSCustomObject]@{ Index=2; NetEnabled=$true; NetConnectionID='Live Migration' }
                        [PSCustomObject]@{ Index=3; NetEnabled=$true; NetConnectionID='Storage-iSCSI' }
                    )
                }
            }
        }

        It "Classifies Management adapter correctly" {
            $result = Get-HVNetworkProfile
            ($result | Where-Object AdapterName -eq 'Management').Role | Should -Be 'Management'
        }
        It "Classifies LiveMigration adapter correctly" {
            $result = Get-HVNetworkProfile
            ($result | Where-Object AdapterName -like '*Live*').Role | Should -Be 'LiveMigration'
        }
        It "Classifies Storage adapter correctly" {
            $result = Get-HVNetworkProfile
            ($result | Where-Object AdapterName -like '*Storage*').Role | Should -Be 'Storage'
        }
        It "Returns correct adapter count" {
            $result = Get-HVNetworkProfile
            $result.Count | Should -Be 3
        }
    }

    Context "CIM failure" {
        It "Returns empty array on failure" {
            Mock Get-CimInstance { throw 'WMI error' }
            $result = Get-HVNetworkProfile
            @($result).Count | Should -Be 0
        }
    }
}

Describe "Get-HVNetworkDrift" {
    Context "Compliant state" {
        It "Returns Score=0 when all networks match" {
            Mock Get-ClusterNetwork {
                @([PSCustomObject]@{ Name='Cluster Network 1'; Role=3 })
            }
            $result = Get-HVNetworkDrift -DesiredRoleMap @{ 'Cluster Network 1' = 3 }
            $result.Score | Should -Be 0
        }
    }
    Context "Drifted state" {
        It "Adds score when network role mismatches" {
            Mock Get-ClusterNetwork {
                @([PSCustomObject]@{ Name='Cluster Network 1'; Role=0 })
            }
            $result = Get-HVNetworkDrift -DesiredRoleMap @{ 'Cluster Network 1' = 3 }
            $result.Score | Should -BeGreaterThan 0
        }
        It "Adds score when network is missing" {
            Mock Get-ClusterNetwork { @() }
            $result = Get-HVNetworkDrift -DesiredRoleMap @{ 'Missing Net' = 3 }
            $result.Score | Should -BeGreaterThan 0
        }
    }
}
