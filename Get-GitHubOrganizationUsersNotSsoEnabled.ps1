<#
.SYNOPSIS
    List all GitHub users in an Organization who are not enabled for Single Sign-On (SSO). A GitHub Personal Access Token (PAT) with the admin:org scope for the Organization being queried is required to run this script. Find more random GitHub scripts at: https://github.com/benarculus/github-tools/.


.PARAMETER OrganizationName
    Mandatory, provide the name of the GitHub Organization, this is not case sensitive.

#.PARAMETER CSVPath
#    Optional, provide a location on where to save the outputs of this script as a CSV file. By default, this will save the CSV file to the running directory.
#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$OrganizationName,
        [Parameter(Mandatory=$false)]
        [String]$Token#,
        #[Parameter(Mandatory=$false)]
        #[String]$CSVPath
    )

# Reused variables:    
# Securely store the GitHub Personal Access Token (PAT)
$pat = Read-Host -Prompt "Enter your PAT:" -AsSecureString

# 1: List all users in the organization

# GraphQL query to get all users in the organization
$query1 = @"

"@


try {
    $ocRequest = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Authentication OAuth -Token $pat -Method 'POST' -Body (ConvertTo-Json $query1)
}
catch {
    Write-Host $_.ErrorDetails.Message
} 

# 2: List all sso enabled users in the organization
# GraphQL query to get all sso enabled users in the organization
# Query is retrieved from @drhayes at: https://gist.github.com/drhayes/13d1e028f6bb7567b936f79064dfe66c
$query2 = @{}
$key = "query"
$value = @"
query {
    organization(login: "$org") {
      samlIdentityProvider {
        ssoUrl
        externalIdentities(first: 100) {
          edges {
            node {
              guid
              samlIdentity {
                nameId
              }
              user {
                login
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    }
  }
"@
$query2[$key] = $value

# try the query
try {
    $ssoEnabledUsers =  Invoke-RestMethod -Uri "https://api.github.com/graphql" -Authentication OAuth -Token $pat -Method 'POST' -Body (ConvertTo-Json $query2)
}
catch {
    Write-Host $_.ErrorDetails.Message
    Write-Host $_.errors
} 

# 3: Remove users that are enabled from the initial user list


# Try first to use the path provided, if that fails, then catch with creating the file from the working directory
try {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the provided path
    $workflowList | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path $CSVPath/Repos-with-Actions-Workflows.csv
}
catch {
    # Convert the hashtable to a PSCustomObject and export as a CSV to the 
    $workflowList | ForEach-Object { [PSCustomObject]$_} | Export-Csv -Path ./Repos-with-Actions-Workflows.csv
}
