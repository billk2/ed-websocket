Unregister-Event -SourceIdentifier FileChanged

#Write-Host "monitor.ps1"
# test git

$dir = "C:\Users\$env:UserName\Saved Games\Frontier Developments\Elite Dangerous"
#$dir = "F:\" #debug
#$dir = "\\vboxsrv\journals"
$filter = "*.log"
$global:FileChanged = $false
$global:fileLengthLast = 0


#$dir = "C:\Users\IEUser\logs" # debug
#$filter = "*.txt" #debug


$Watcher = New-Object IO.FileSystemWatcher $dir, $filter -Property @{
  IncludeSubdirectories = $false;
  NotifyFilter = [System.IO.NotifyFilters]'FileName,LastWrite'
}

Write-Host $dir



Register-ObjectEvent $Watcher Changed -SourceIdentifier FileChanged -Action {
 $latestLog = $Event.SourceEventArgs.Name
 $global:fullPath = "$dir\$latestLog"
 Write-Host $global:fullPath
 $lines = Get-Content $global:fullPath | Measure-Object -Line
 if ($lines.Lines -ne $global:fileLengthLast) {
   $global:fileLengthChange = $lines.Lines - $global:fileLengthLast
#   Write-Host "changed lines: $global:fileLengthChange"
   $global:fileLengthLast = $lines.Lines
#   Write-Host "changed fileLengthLast: $global:fileLengthLast"
   $global:FileChanged = $true
 }
# } | Out-Null
}


while ($true) {

    while ($global:FileChanged -eq $true){
      $global:FileChanged = $false
      Get-Content $global:fullPath | Select-Object -Last $global:fileLengthChange
      Write-Host "fileLengthChange: $global:fileLengthChange"
    }

}
