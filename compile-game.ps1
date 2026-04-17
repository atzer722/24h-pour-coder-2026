$mainFile = ".\src\main.fnl"
$outputFile = ".\src\main_.fnl"

if (-not (Test-Path $mainFile)) {
    Write-Error "The main file doesn't exist!"
    exit 1
}

$lines = Get-Content $mainFile -Encoding UTF8
$result = @()

foreach ($line in $lines) {
    if ($line -match '<import\s+(.+\.fnl)\s*>') {
        $importedFile = $matches[1].Trim()

        if (-not (Test-Path $importedFile)) {
            $importedFile = ".\src\$importedFile"
        }

        if (-not (Test-Path $importedFile)) {
            Write-Error "The imported file '$importedFile' doesn't exist!"
            exit 2
        }

        $importedLines = Get-Content $importedFile -Encoding UTF8
        $result += $importedLines
    } else {
        $result += $line
    }
}

$result | Set-Content $outputFile -Encoding UTF8
Write-Host "Compilation ended : $outputFile"