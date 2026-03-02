#Requires -Modules Pester
BeforeAll {
    . "$PSScriptRoot\_Stubs.ps1"
    . "$PSScriptRoot\..\Private\Logging.ps1"
    . "$PSScriptRoot\..\Private\LiveMigration.ps1"
    Mock Write-HVLog { }
}

Describe "Get-HVMigrationReadiness" {
    Context "Ready node" {
        BeforeEach {
            Mock Get-ClusterNode  { [PSCustomObject]@{ Name='NODE1'; State='Up' } }
            Mock Get-ClusterNetwork { @([PSCustomObject]@{ Role=3 }) }
            Mock Get-VMHost { [PSCustomObject]@{ VirtualMachineMigrationEnabled=$true; VirtualMachineMigrationAuthenticationType='Kerberos'; MaximumVirtualMachineMigrations=2 } }
            Mock Get-VMHostSupportedVersion { @() }
        }
        It "Returns Ready=true for a healthy node" {
            $result = Get-HVMigrationReadiness -Nodes @('NODE1')
            $result[0].Ready | Should -Be $true
        }
    }

    Context "Migration disabled" {
        It "Returns Ready=false when VM migration is disabled" {
            Mock Get-ClusterNode  { [PSCustomObject]@{ Name='NODE1'; State='Up' } }
            Mock Get-VMHost { [PSCustomObject]@{ VirtualMachineMigrationEnabled=$false } }
            Mock Get-ClusterNetwork { @([PSCustomObject]@{ Role=3 }) }
            $result = Get-HVMigrationReadiness -Nodes @('NODE1')
            $result[0].Ready | Should -Be $false
            ($result[0].Issues | Where-Object { $_ -match 'disabled' }) | Should -Not -BeNullOrEmpty
        }
    }

    Context "Node down" {
        It "Returns issue for node not in Up state" {
            Mock Get-ClusterNode  { [PSCustomObject]@{ Name='NODE1'; State='Down' } }
            Mock Get-VMHost { [PSCustomObject]@{ VirtualMachineMigrationEnabled=$true } }
            Mock Get-ClusterNetwork { @([PSCustomObject]@{ Role=3 }) }
            $result = Get-HVMigrationReadiness -Nodes @('NODE1')
            $result[0].Ready | Should -Be $false
        }
    }
}

Describe "Start-HVLiveMigration" {
    Context "Successful migration" {
        BeforeEach {
            Mock Get-ClusterNode  { @([PSCustomObject]@{ Name='NODE2'; State='Up' }) }
            Mock Get-VMHost       { [PSCustomObject]@{ VirtualMachineMigrationEnabled=$true } }
            Mock Get-ClusterNetwork { @([PSCustomObject]@{ Role=3 }) }
            Mock Move-ClusterVirtualMachineRole { }
            Mock Get-ClusterGroup { [PSCustomObject]@{ Name='VM01'; OwnerNode=[PSCustomObject]@{Name='NODE2'} } }
        }
        It "Returns Success=true for a migrated VM" {
            $result = Start-HVLiveMigration -VMNames @('VM01') -DestinationNode 'NODE2' -SkipReadinessCheck
            $result[0].Success | Should -Be $true
        }
    }

    Context "Failed migration" {
        It "Returns Success=false when Move-ClusterVirtualMachineRole throws" {
            Mock Get-ClusterNode  { @([PSCustomObject]@{ Name='NODE2'; State='Up' }) }
            Mock Get-VMHost       { [PSCustomObject]@{ VirtualMachineMigrationEnabled=$true } }
            Mock Get-ClusterNetwork { @([PSCustomObject]@{ Role=3 }) }
            Mock Move-ClusterVirtualMachineRole { throw 'Migration failed' }
            $result = Start-HVLiveMigration -VMNames @('VM01') -DestinationNode 'NODE2' -SkipReadinessCheck
            $result[0].Success | Should -Be $false
        }
    }
}
