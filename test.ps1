# --- Core signal ---
Write-Output "Script executed successfully."

# --- Timestamp ---
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# --- Write to a file ---
$outFile = "$env:USERPROFILE\Desktop\script-hub-test.txt"
"Executed at: $time" | Out-File -FilePath $outFile -Encoding utf8 -Append

# --- visible action ---
Start-Sleep -Seconds 1
Write-Output "Output written to Desktop."
