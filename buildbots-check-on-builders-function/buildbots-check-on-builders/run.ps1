# Input bindings are passed in via param block.
param($Timer)

$currentTime = Get-Date

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentTime"

function Get-Builders {
    param (
        $Threshold_Builds
    )

    $builders_result_list = @()

    $builder_prefix = "mgmt-azure-builder-"
    $builders_list = Get-AzVM | Where-Object { $_.Name -match "$builder_prefix*" } | ForEach-Object { $_ | Select-Object Name, @{Name="Number"; Expression={$_.Name.Split("-")[3] }}}

    $vm_prefix = "bot" 
    $buildbots_list = Get-AzVM | Where-Object { $_.Name -match "$vm_prefix*" } | ForEach-Object { $_ | Select-Object Name }

    foreach ($builder in $builders_list) {
        [array]$list = $buildbots_list | Where-Object { $_.Name -match "$vm_prefix-$($builder.Number)-" }
        if ($list.Count -gt $Threshold_Builds) {
            $builders_result_list += "mgmt-azure-builder-$i"
        }
    }

    return $builders_result_list
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

function Post-Slack {
    param (
        $Url,
        $Threshold_Builds,
        $VMs
    )

    $msg_block = @{
        blocks = @(
            @{
                type = "section"
                text = @{
                    type = "mrkdwn"
                    text = ":loudspeaker: *The following builders have more than $Threshold_Builds buildbots spun up currently* :loudspeaker:"
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

function Run {
    param (
        $Client_Id,
        $Client_Secret,
        $Tenant_Id
    )

    # Number to and from builder
    $builders_number_from = $env:AZURE_BUILDERS_FROM
    $builders_number_to = $env:AZURE_BUILDERS_TO

    # Limit of builds that Builder admits
    $threshold_builds = $env:THRESHOLD_BUILDS

    # Slack webhook to post the alert
    $slack_webhook_url = $env:SLACK_WEBHOOK_URL 

    Connect $Client_Id $Client_Secret $Tenant_Id

    $result = Get-Builders $threshold_builds

    if ($result.Count -gt 0) {
        Post-Slack $slack_webhook_url $threshold_builds $result
    } else {
        Write-Host "No builders running more than the threshold number of buildbots"
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
