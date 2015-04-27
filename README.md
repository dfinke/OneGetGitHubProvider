PowerShell PackageManagement GitHub Provider
-
**GitHub-as-a-package**

This PowerShell module implements the PackageManagement PowerShell provider SDK

**NOTE**
* Works only on .NET 4.5 for now. It uses `[System.IO.Compression.ZipFile]::ExtractToDirectory` working on resolving why Expand-Zip and New-Object -COM Shell.Application fail (Need to find a general way to handle unzipping for v5 and previous releases)
