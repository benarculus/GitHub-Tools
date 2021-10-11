<#
.SYNOPSIS
    List all GitHub Repositories in an Organization and count the number of Actions workflows. A GitHub Personal Access Token (PAT) is required to run this script. https://github.com/benarculus/github-tools/
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
        [Parameter(Mandatory=$true)]
        [String]$OrganizationName,
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

<# this did not work, "Invoke-RestMethod: A positional parameter cannot be found that accepts argument 'System.Collections.Hashtable'."
# Set common parameters used for Invoke-Restmethod
$params = @{
    'Authentication' = 'OAuth'
    'Token' = $pat
    'Method' = 'GET'
}
#>

# Set the header for the v3 API.
$headers = @{
    'accept' = 'application/vnd.github.v3+json'
}

# 1: create a list of outside collaborators

# 1.a: create an object listing the organization's outside collaborators.
try {
    $ocRequest = Invoke-RestMethod -Uri "https://api.github.com/orgs/$OrganizationName/outside_collaborators" -Authentication OAuth -Token $pat -Method 'GET' -Headers $headers
}
catch {
    Write-Host $_.ErrorDetails.Message
} 

# 1.b: transform the object to a list
#write something


# 2: update outside collaborator list with a tally for any commits in the last year

# 2.a: get every repo in the organization
try {
    $orgRepos =  Invoke-RestMethod -Uri "https://api.github.com/orgs/$OrganizationName/repos" -Authentication OAuth -Token $pat -Method 'GET' -Headers $headers
}
catch {
    Write-Host $_.ErrorDetails.Message
} 

# 2.b: get the commits from every repo
$orgRepos.name | ForEach-Object {

    # 2.b.1: create an object for the commit response
    try {
        $commits = Invoke-RestMethod -Uri "https://api.github.com/repos/$OrganizationName/$_/commits" -Authentication OAuth -Token $pat -Method 'GET' -Headers $headers
    }
    catch {
        Write-Host $_.ErrorDetails.Message
    } 

    # 2.b.2: write committer name, email, and date
    
    #if date is greater than 1 year from now
        #then write details to list or object
}

# 2.c: tally commits by outside collaborators

# 3: update outside collaborator list with a tally for any issues submitted in the last year

# 3.a: get issues from every repo
$orgRepos.name | ForEach-Object {

    # 3.a.1: create an object for the issues reponse
    try {
        #$something = Invoke-RestMethod -Uri " " -Authentication OAuth -Token $pat -Method 'GET' -Headers $headers
    }
    catch {
        Write-Host $_.ErrorDetails.Message
    } 

    # 3.a.2: write [committer name, email, and date - check on values]
    
    #if date is greater than 1 year from now
        #then write details to list or object

}

# 4: write list to a csv file on disk

# Try first to use the path provided, if that fails, then catch with creating the file from the working directory
try {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the provided path
    $workflowList | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path $CSVPath/Repos-with-Actions-Workflows.csv
}
catch {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the 
    $workflowList | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path ./Repos-with-Actions-Workflows.csv
}
