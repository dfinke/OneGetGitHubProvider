Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$Providername = "GitHub"
$GitHubPath   = "$env:LOCALAPPDATA\OneGet\GitHub"
$CSVFilename  = "$($GitHubPath)\OneGetData.csv"

function Get-GitHubAuthHeader {
    param(
    	[pscredential]$Credential
    )    

    $authInfo = "{0}:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password
    $authInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authInfo))

    @{
        "Authorization" = "Basic " + $authInfo
        "Content-Type" = "application/json"
    }
}

function Expand-ZIPFile($file, $destination) {

    $shell = new-object -com shell.application
    $zip   = $shell.NameSpace($file)

    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item)
    }
}

function Initialize-Provider     { write-debug "In $($Providername) - Initialize-Provider" }
function Get-PackageProviderName { return $Providername }

function Resolve-PackageSource { 

    write-debug "In $($ProviderName)- Resolve-PackageSources"    
    
    $IsTrusted    = $false
    $IsRegistered = $false
    $IsValidated  = $true
    
    foreach($Name in @($request.PackageSources)) {
    	$Location = "https://api.github.com/users/$($Name)/repos"
    	
    	write-debug "In $($ProviderName)- Resolve-PackageSources repo: {0}" $Location

        New-PackageSource $Name $Location $IsTrusted $IsRegistered $IsValidated
    }        
}

function Find-Package { 
    param(
        [string[]] $names,
        [string] $requiredVersion,
        [string] $minimumVersion,
        [string] $maximumVersion
    )

	write-debug "In $($ProviderName)- Find-Package"
	
	ForEach($Name in @($request.PackageSources)) {
	    
	    write-debug "In $($ProviderName)- Find-Package for user {0}" $Name
	    
	    if($request.Credential) { $Header = (Get-GitHubAuthHeader $request.Credential) }	    
	    
	    ForEach($repo in (Invoke-RestMethod "https://api.github.com/users/$($Name)/repos" -Header $Header)) {
	    	
	    	if($request.IsCancelled){break}
	        
	        write-debug "In $($ProviderName)- Find-Package found file {0}" $repo.name	        
        
	        $fastPackageReference = $repo.archive_url.Replace('api.','').Replace('/repos','').Replace('{archive_format}','archive').Replace('{/ref}','/master.zip')
	        
		if($repo.description -eq $null) {
		    $summary = ""
		} else {
		    $summary = ($repo.description).tostring()
		}
		
	        if($repo.name -match $names) {
	            $SWID = @{
	                version              = "1.0"
	                versionScheme        = "semver"
	                fastPackageReference = $fastPackageReference
	                name                 = $repo.name
	                source               = "GitHub/$($Name)"
	                summary              = $summary
	                searchKey            = $repo.name
	            }           
	            
	            $SWID.fastPackageReference = $SWID | ConvertTo-JSON -Compress
	            New-SoftwareIdentity @SWID
	        }
	    }
	}
}

function Install-Package { 
    param(
        [string] $fastPackageReference
    )   	
    	$rawUrl = ($fastPackageReference|ConvertFrom-Json).fastpackagereference
	
	write-debug "In $($ProviderName) - Install-Package - {0}" $rawUrl
	
	if(!(Test-Path $GitHubPath)) { md $GitHubPath | Out-Null }		
	
	$TempZipFile = (Split-Path -Leaf ([System.IO.Path]::GetTempFileName())).Replace(".tmp",".zip")
	$TempZipFile = Join-Path $GitHubPath $TempZipFile
		
	Invoke-RestMethod -Uri $rawUrl -OutFile $TempZipFile 	
	
	write-debug "In $($ProviderName) - Expand-Zip -ZipPath {0} -OutputPath {1}" $TempZipFile $GitHubPath
	#https://github.com/dfinke/BladePS/archive/master.zip
	
	write-verbose "Package intstall location {0}\{1}-master" $GitHubPath ($rawUrl.split("/")[4])

	[System.IO.Compression.ZipFile]::ExtractToDirectory($TempZipFile, $GitHubPath)
	Remove-Item $TempZipFile
	
	($fastPackageReference | ConvertFrom-Json) |
	     Export-Csv -Path $CSVFilename -Append -NoTypeInformation -Encoding ASCII -Force	
}

function ConvertTo-HashTable {
    param(
        [Parameter(ValueFromPipeline)]
        $Data
    )

    process {
        if(!$Fields) {            
            $Fields=($Data|Get-Member -MemberType NoteProperty ).Name
        }
        
        $h=[Ordered]@{}
        foreach ($Field in $Fields)
        {
            $h.$Field = $Data.$Field                        
        }
        $h
    }
}

function Get-InstalledPackage {
    param()

    if(Test-Path $CSVFilename) {
        $installedPackages = Import-Csv $CSVFilename
        
        write-debug "In $($ProviderName) - Get-InstalledPackage {0}" @($installedPackages).Count   
        
        foreach ($item in ($installedPackages | ConvertTo-HashTable))
        {    
            New-SoftwareIdentity @item
        }
    }
}