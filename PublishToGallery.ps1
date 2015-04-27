$p = @{
    Name = "GitHubProvider"
    NuGetApiKey = $NuGetApiKey 
    LicenseUri = "https://github.com/dfinke/OneGetGistProvider/blob/master/LICENSE" 
    Tag = "Github","PackageManagement","Provider"
    ReleaseNote = "Updated to work with rename to PackageManagement"
    ProjectUri = "https://github.com/dfinke/OneGetGitHubProvider"
}

Publish-Module @p