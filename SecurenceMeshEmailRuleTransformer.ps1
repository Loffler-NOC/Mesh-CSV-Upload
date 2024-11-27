# Prompt for the CSV file, domain, and choice
$csvFile = Read-Host "Enter the path to the CSV file (with or without quotes)"
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
        sender    = ""
        recipient = ""
        rule      = $choice
    }
    # Start Processing Logic
    if ($row.Rule -match '^(?i)from\+') {
        if ($row.Rule.Contains('*')) {
            $address = $row.Rule -replace '^.*@', ''
        }
        else {
            $address = $row.Rule -replace '^.*:', ''
        }
        $newRow.sender = $address
        $newRow.recipient = $domain
    }
    elseif ($row.Rule -match '^(?i)to\+') {
        if ($row.Rule.Contains('*')) {
            $address = $row.Rule -replace '^.*@', ''
        }
        else {
            $address = $row.Rule -replace '^.*:', ''
        }
        $newRow.recipient = $address
        $newRow.sender = $domain
    }
    elseif ($row.Rule -match '^(?i)ip:') {
        continue # Skip this row
    }
    else {
        continue # Skip any other rows that don't match the criteria
    }
    # End Processing Logic
    if ($newRow.sender -ne "" -or $newRow.recipient -ne "") {
        $newData += $newRow
    }
}

# Export the new data to a new CSV file
$newCsvFile = "new_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".csv"
$newData | Export-Csv -Path $newCsvFile -NoTypeInformation

# Print the full path of the new CSV file
$fullPath = (Resolve-Path -Path $newCsvFile).Path
Write-Host "New CSV file created: $fullPath"
