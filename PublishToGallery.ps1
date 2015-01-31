$p = @{
    Name = "GitHubProvider"
    NuGetApiKey = $NuGetApiKey 
    LicenseUri = "https://github.com/dfinke/OneGetGistProvider/blob/master/LICENSE" 
    Tag = "Github","OneGet","Provider"
    ReleaseNote = "GitHub-as-a-Package - OneGet PowerShell Provider to interop with Github"
    ProjectUri = "https://github.com/dfinke/OneGetGitHubProvider"
}

Publish-Module @p