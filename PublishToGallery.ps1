$p = @{
    Name = "GitHubProvider"
    NuGetApiKey = $NuGetApiKey 
    LicenseUri = "https://github.com/dfinke/OneGetGistProvider/blob/master/LICENSE" 
    Tag = "Github","OneGet","Provider","Start-Automating"
    ReleaseNote = "Fixed summary property error when it is null in GitHub"
    ProjectUri = "https://github.com/dfinke/OneGetGitHubProvider"
}

Publish-Module @p