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
    [String]$TargetPath,

    [Parameter(Mandatory=$false)]
    [Switch]$DeleteFromInbox
)
$client = [MailKit.Net.Imap.ImapClient]::new()
$client.Connect($IMAPServer, $Port)
$client.Authenticate($Username, $Password)
$access = [MailKit.FolderAccess]::ReadWrite
$client.Inbox.Open($access)
$items = [MailKit.MessageSummaryItems]::UniqueId
$ids = $client.Inbox.Fetch(0, -1, $items) | select UniqueId, Index
$flag = [MailKit.MessageFlags]::Deleted
foreach ($id in $ids) {
    if ($client.Inbox.GetMessage($id.UniqueId).BodyParts.IsAttachment -eq $true) {
    $stream = [System.IO.File]::Create("$($TargetPath)$($attachment.FileName)")
    $attachment.ContentObject.DecodeTo($stream)
    $stream.Close()
        if ($DeleteFromInbox) {
            $client.Inbox.SetFlags($id.UniqueId, $flag, $true)
        }
    }
  }
}
