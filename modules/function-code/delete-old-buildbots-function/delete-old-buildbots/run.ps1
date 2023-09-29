# Input bindings are passed in via param block.
param($Timer)

$currentTime = Get-Date

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentTime"

function Get-Buildbots {
    param (
        $Threshold_Days
    )

    $bots_to_delete = @()

    $vm_prefix = "bot-"
    $bots = Get-AzVM | Where-Object { $_.Name -match "$vm_prefix*" } | ForEach-Object {
        $vm = $_
        $vm | Select-Object Name, ResourceGroupName, Location, TimeCreated
    }

    foreach ($vm in $bots) {
        $days = ((Get-Date).Date.Subtract($vm.TimeCreated.Date)).TotalDays
        if ($days -ge $Threshold_Days) {
            $bots_to_delete += $vm
        }
    }

    Write-Host "VMs marked for deletion $($bots_to_delete.Name -join ", ")"

    return $bots_to_delete
}

function Delete-Instance {
    param (
        $VM
    )
    
    $result = (Remove-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force)
    if ($result.Status -eq "Succeeded") {
        Remove-AzNetworkInterface -ResourceGroupName $VM.ResourceGroupName -Name "$($VM.Name)NIC" -Force
        $VM.Deleted = $true
    } else {
        Write-Error "VM was not deleted $($result.Error)"
        $VM.Deleted = $false
    }
}

function Post-Slack {
    param (
        $Url,
        $VMs,
        $is_error
    )
    
    if ($is_error) {
        $msg_title = ":loudspeaker: :warning: *Alert from AzureFunction! The following buildbot VMs failed being deleted* :warning: :loudspeaker:"
    } else {
        $msg_title = ":loudspeaker: *Alert from AzureFunction! The following buildbot VMs are being deleted* :loudspeaker:"
    }

    $msg_block = @{
        blocks = @(
            @{
                type = "section"
                text = @{
                    type = "mrkdwn"
                    text = "$msg_title"
                }
            },
            @{
                type = "section"
                text = @{
                    type = "mrkdwn"
                    text = "$($VMs.Name -join "\n") "
                }
            }
        )
    } | ConvertTo-Json -Depth 4
    
    Invoke-RestMethod -Uri $Url -Method Post -Body $msg_block
}

function Connect {
    param (
        $Client_Id,
        $Client_Secret,
        $Tenant_Id
    )
    $PSCredential = New-Object System.Management.Automation.PSCredential($Client_Id, ($Client_Secret | ConvertTo-SecureString -AsPlainText -Force))
    Connect-AzAccount -ServicePrincipal -Credential $PSCredential -Tenant $Tenant_Id
}

function Run {
    param (
        $Client_Id,
        $Client_Secret,
        $Tenant_Id
    )
    # Limit of days that can be created a VM
    $threshold_days = $env:THRESHOLD_DAYS

    # Slack webhook to post the alert
    $slack_webhook_url = $env:SLACK_WEBHOOK_URL 
    
    Connect $Client_Id $Client_Secret $Tenant_Id
    $result = Get-Buildbots $threshold_days    
    if ($result.Count -gt 0) {
        Post-Slack $slack_webhook_url $result $false
        foreach ($vm in $result) { 
            Delete-Instance $vm
        }
        $bots_failed = $result | Where-Object { -not $_.Deleted }
        if ($bots_failed.Count -gt 0) {
            Post-Slack $slack_webhook_url $bots_failed $true
        }
    }
}

$sp_credentials = @(
    @{
        Name         = "iac-7028-devops-cloudbuild-test"
        Client_Id     = $env:AZURE_TEST_CLIENT_ID
        Client_Secret = $env:AZURE_TEST_CLIENT_SECRET
        Object_Id     = $env:AZURE_TEST_OBJECT_ID
    },
    @{
        Name         = "iac-7028-devops-cloudbuild-stg"
        Client_Id     = $env:AZURE_STG_CLIENT_ID
        Client_Secret = $env:AZURE_STG_CLIENT_SECRET
        Object_Id     = $env:AZURE_STG_OBJECT_ID
    }
)

foreach ($sp_cred in $sp_credentials) {
    Write-Host "Checking SP $($sp_cred.Name)"
    Run $sp_cred.Client_Id $sp_cred.Client_Secret $sp_cred.Object_Id
}
