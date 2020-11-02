$moduleExists = Get-Module -Name 'Mailozaurr'
if (!$moduleExists) {
    Install-Module Mailozaurr
}
Import-Module Mailozaurr
function Save-MailAttachments {
param(
    [Parameter(Mandatory=$true)]
    [String]$IMAPServer,

    [Parameter(Mandatory=$true)]
    [Int32]$Port,

    [Parameter(Mandatory=$true)]
    [String]$Username,

    [Parameter(Mandatory=$true)]
    [String]$Password,

    [Parameter(Mandatory=$true)]
    [String]$TargetPath
)
$fileDir = $TargetPath
$client = Connect-IMAP -Server $IMAPServer -Port $Port -UserName $Username -Password $Password
$access = [MailKit.FolderAccess]::ReadWrite
$folder = Get-IMAPFolder -Client $client -FolderAccess $access
$messages = $folder.Messages
$attachments = $messages[-1].BodyParts | where {$_.IsAttachment -eq $true}
foreach ($attachment in $attachments) {
    $stream = [System.IO.File]::Create("$($fileDir)$($attachment.FileName)")
    $filePath = "$($fileDir)$($attachment.FileName)"
    $attachment.ContentObject.DecodeTo($stream)
    $stream.Close()
}
}



