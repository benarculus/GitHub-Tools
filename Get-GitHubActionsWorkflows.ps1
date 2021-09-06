<#
Need intro/help
#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$OrganizationName,
        [Parameter(Mandatory=$false)]
        [String]$PATPath
    )

# Securely store the GitHub Personal Access Token (PAT). https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.1
$pat = {
    # Check to see if a PAT path was provided
    if ($PATPath -ne $null){
        # If a PAT path was provided, then get the content of the file and store it as a secure string
        Get-Content -Path $PATPath | ConvertTo-SecureString
    }
    else {
        # Otherwise have the user manually enter their PAT and store it as a secure string
        Read-Host -Prompt "Enter your PAT:" -AsSecureString      
    }
}

# Set the header to be used on GitHub API requests
$header = @{
    'accept' = 'application/vnd.github.v3+json'
    'token' = "$pat"
}

# Set the URI for listing GitHub Repositories in an organization
$repoUrl = "https://api.github.com/orgs/$OrganizationName/repos"

# Get the full list of all Repositories in the organization
$repos = Invoke-RestMethod -Uri $repoUrl -Headers $header -Method 'POST'

# Maybe not needed - Create a list from the full Repository listing of just the repository names (full_name)

# Check each repo for Actions workflows
$repos.full_name | ForEach-Object { 
    # Store the repo name
    $output = @{
        "$_" = @{
            "workflows" = ""
        }
    }

    # Set the URI for listing GitHub Actions within a repository
    $actionsUrl = "https://api.github.com/repos/$OrganizationName/$_/actions/workflows"
    
    # List the Actions for the repo
    $actions = Invoke-RestMethod -Uri $actionsUrl -Headers $header -Method 'POST'

    # Record the count of the Actions workflows
    Add-Content $output.$_.workflows -Value "$actions.total_count"
}

# Write the output to the user
Write-Output -InputObject $output