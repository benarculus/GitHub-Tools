<#
.SYNOPSIS
    List all GitHub Repositories in an Organization and count the number of Actions workflows. A GitHub Personal Access Token (PAT) is required to run this script. https://github.com/benarculus/github-tools/

.PARAMETER OrganizationName
    Mandatory, provide the name of the GitHub Organization, this is not case sensitive.

.PARAMETER CSVPath
    Optional, provide a location on where to save the outputs of this script as a CSV file. By default, this will save the CSV file to the running directory.
#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$OrganizationName,
        [Parameter(Mandatory=$true)]
        [String]$CSVPath
    )
    
# Securely store the GitHub Personal Access Token (PAT). https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.1
$pat = Read-Host -Prompt "Enter your PAT:" -AsSecureString

# Set the header to be used on GitHub API requests
$header = @{
    'accept' = 'application/vnd.github.v3+json'
}

# Set the URI for listing GitHub Repositories in an organization
$repoUrl = "https://api.github.com/orgs/$OrganizationName/repos"

# Create the hashtable that will store the results of the GET request used to check for repos with Actions workflows
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

# Try first to use the path provided, if that fails, then catch with creating the file from the working directory
try {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the provided path
    $workflowList | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path $CSVPath/Repos-with-Actions-Workflows.csv
}
catch {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the 
    $workflowList | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path ./Repos-with-Actions-Workflows.csv
}
