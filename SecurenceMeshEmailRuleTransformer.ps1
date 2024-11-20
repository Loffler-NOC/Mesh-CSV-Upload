# Prompt for the CSV file, domain, and choice
$csvFile = Read-Host "Enter the path to the CSV file"
$domain = Read-Host "Enter the domain"
$choice = Read-Host "Enter 'allow' or 'block'"

# Remove quotes from the CSV file path if present
$csvFile = $csvFile -replace '"', ''

# Read the CSV file
$data = Import-Csv -Path $csvFile

# Create a new array to hold the new data
$newData = @()

# Process each row in the CSV
foreach ($row in $data) {
    $newRow = [PSCustomObject]@{
        sender = ""
        recipient = ""
        rule = $choice
    }

    if ($row.Rule -match '^(?i)from') {
        $newRow.sender = $row.Rule -replace '.*:', ''
        $newRow.recipient = $domain
    } elseif ($row.Rule -match '^(?i)to') {
        $newRow.sender = $domain
        $newRow.recipient = $row.Rule -replace '.*:', ''
    }

    $newData += $newRow
}

# Export the new data to a new CSV file
$newCsvFile = "new_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".csv"
$newData | Export-Csv -Path $newCsvFile -NoTypeInformation

# Print the full path of the new CSV file
$fullPath = (Resolve-Path -Path $newCsvFile).Path
Write-Host "New CSV file created: $fullPath"