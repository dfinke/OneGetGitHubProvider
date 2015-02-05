$p = @{
    Name = "GitHubProvider"
    NuGetApiKey = $NuGetApiKey 
    LicenseUri = "https://github.com/dfinke/OneGetGistProvider/blob/master/LICENSE" 
    Tag = "Github","OneGet","Provider","Start-Automating"
    ReleaseNote = "-VERBOSE displays the location of the installed package"
    ProjectUri = "https://github.com/dfinke/OneGetGitHubProvider"
}

Publish-Module @p