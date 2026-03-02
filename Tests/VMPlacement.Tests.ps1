#Requires -Modules Pester
BeforeAll {
    . "$PSScriptRoot\_Stubs.ps1"
    . "$PSScriptRoot\..\Private\Logging.ps1"
    . "$PSScriptRoot\..\Private\VMPlacement.ps1"
    Mock Write-HVLog { }
}

Describe "Get-HVVMPlacementState" {
    It "Returns empty VMs when no VM groups exist" {
        Mock Get-ClusterGroup { @() }
        $result = Get-HVVMPlacementState
        @($result.VMs).Count | Should -Be 0
    }

    It "Returns VM list with expected properties" {
        $fakeGroup = [PSCustomObject]@{
            Name          = 'VM-TestVM01'
            GroupType     = 'VirtualMachine'
            PreferredOwner= @([PSCustomObject]@{ Name='NODE1' })
            OwnerNode     = [PSCustomObject]@{ Name='NODE1' }
            State         = 'Online'
        }
        Mock Get-ClusterGroup { @($fakeGroup) }
        Mock Get-ClusterGroupProperty { @() }

        $result = Get-HVVMPlacementState
        @($result.VMs).Count | Should -Be 1
        $result.VMs[0].VMName | Should -Be 'VM-TestVM01'
    }
}

Describe "Get-HVVMPlacementDrift" {
    Context "No desired policy" {
        It "Returns Score=0 with no policy defined" {
            $result = Get-HVVMPlacementDrift
            $result.Score | Should -Be 0
        }
    }

    Context "Missing VM" {
        It "Scores drift when VM not found" {
            Mock Get-ClusterGroup { throw 'Not found' }
            $result = Get-HVVMPlacementDrift -DesiredPreferredOwners @{ 'NonExistentVM' = @('NODE1') }
            $result.Score | Should -BeGreaterThan 0
        }
    }

    Context "Correct placement" {
        It "Returns Score=0 when preferred owners match" {
            $fakeGroup = [PSCustomObject]@{
                Name           = 'VM-TestVM01'
                PreferredOwner = @([PSCustomObject]@{ Name='NODE1' }, [PSCustomObject]@{ Name='NODE2' })
            }
            Mock Get-ClusterGroup { $fakeGroup }
            $result = Get-HVVMPlacementDrift -DesiredPreferredOwners @{ 'VM-TestVM01' = @('NODE1','NODE2') }
            $result.Score | Should -Be 0
        }
    }
}
