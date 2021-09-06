<#
.SYNOPSIS
    List all GitHub Repositories in an Organization and count the number of Actions workflows. https://github.com/benarculus/github-tools/

.PARAMETER OrganizationName
    Mandatory, provide the name of the GitHub Organization, this is not case sensitive.

#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$OrganizationName
    )

# Securely store the GitHub Personal Access Token (PAT). https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.1
$pat = Read-Host -Prompt "Enter your PAT:" -AsSecureString

# Set the header to be used on GitHub API requests
$header = @{
    'accept' = 'application/vnd.github.v3+json'
}

# Set the URI for listing GitHub Repositories in an organization
$repoUrl = "https://api.github.com/orgs/$OrganizationName/repos"

# Create the list that will store the results of the GET request used to check for repos with Actions workflows
$workflowList = @{}

# Get the full list of all Repositories in the organization
$repos = Invoke-RestMethod -Uri $repoUrl -Authentication OAuth -Token $pat -Headers $header -Method 'GET'

# Check each repo for Actions workflows
$repos.name | ForEach-Object { 

    # Set the URI for listing GitHub Actions within a repository
    $actionsUrl = "https://api.github.com/repos/$OrganizationName/$_/actions/workflows"
    
    # List the Actions for the repo
    $actions = Invoke-RestMethod -Uri "$actionsUrl" -Authentication OAuth -Token $pat -Headers $header -Method 'GET'

    # Record the count of the Actions workflows
    $workflowList.add($_, $actions.total_count)
}

# Write the output to the user
Write-Output -InputObject $workflowList
