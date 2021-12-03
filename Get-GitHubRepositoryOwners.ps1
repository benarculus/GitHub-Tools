<#
.SYNOPSIS
    List the owners of all GitHub Repositories in scope. https://github.com/benarculus/github-tools/
    Reqs: 
        Get outside collaborators (email too if possible)
        pull commit authors for every repo in an org in the last year
        compare outside collaborate list to authors - mark if they have authored or not

.PARAMETER OrganizationName
    Mandatory, provide the name of the GitHub Organization, this is not case sensitive.

.PARAMETER CSVPath
    Optional, provide a location on where to save the outputs of this script as a CSV file. By default, this will save the CSV file to the running directory.
#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [String]$URL,        
        [Parameter(Mandatory=$false)]
        [String]$OrganizationName,
        [Parameter(Mandatory=$false)]
        [String]$EnterpriseName,
        [Parameter(Mandatory=$false)]
        [String]$Token,
        [Parameter(Mandatory=$false)]
        [String]$DormantSince,
        [Parameter(Mandatory=$false)]
        [String]$CSVPath
    )

# Reused variables:    
# Securely store the GitHub Personal Access Token (PAT)
$pat = Read-Host -Prompt "Enter your PAT:" -AsSecureString

# Set the header for the v3 API.
$headers = @{'accept' = 'application/vnd.github.v3+json'}

# Create a custom PowerShell object that will store the results of the query
$repoOwners = @()

# Add logic here to determine server or dotcom
# Enterprise Server url
$selfHostedURL = "$hostname/api/v3/"
# Cloud $selfHostedURL = "https://api.github.com"

# Get the organizations within the enterprise.
# https://docs.github.com/en/enterprise-server@latest/rest/reference/orgs#list-organizations
# Add a switch for dotcom
try {
    $orgList = Invoke-RestMethod -Uri "$selfHostedURL/organizations" -Authentication OAuth -Token $pat -Method 'GET' -Headers $headers
}
catch {
    Write-Host $_.Exception.Message
} 

# Get the repositories in each org, along with their owners
# https://docs.github.com/en/enterprise-server@latest/rest/reference/repos#list-organization-repositories
$orgList.login | ForEach-Object {
    try {
        $repoList = Invoke-RestMethod -Uri "$selfHostedURL/orgs/$_/repos" -Authentication OAuth -Token $pat -Method 'GET' -Headers $headers
    }
    catch {
        Write-Host $_.Exception.Message
    } 
    # For each repository get the full_name and owner usernames
    $repoList.full_name | ForEach-Object {
        
        # Add repository full_name and usernames to $repoOwners object
        $repoOwners +=  @{
            Repository = $_
            Owner = $repoList.owner.login
        }
    }
}

# Save to CSV
# Try first to use the path provided, if that fails, then catch with creating the file from the working directory
try {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the provided path
    $repoOwners | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path $CSVPath/Repos-with-Actions-Workflows.csv
}
catch {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the 
    $repoOwners | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path ./Repos-with-Actions-Workflows.csv
}
