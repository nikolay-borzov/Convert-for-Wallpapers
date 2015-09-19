<# 
 .Synopsis
  Shows notification in tray. Allows to open folder in explorer

 .Description
  Sources http://www.powertheshell.com/balloontip/
          http://stackoverflow.com/questions/2118093/powershell-2-event-handling
  Icon http://www.iconarchive.com/show/material-icons-by-zhoolego/Images-icon.html

 .Parameter Title
  Notification title.

 .Parameter Text
  Notification text.

 .Parameter OpenPath
  Path to open in explorer when notification clicked.

 .Parameter Icon
  Notification icon: 'None', 'Info', 'Warning', 'Error'

 .Parameter Timeout
  Notification timeout in milliseconds.

 .Example
  # 
  Show-CompleteNortification  "Success" "Operation completed"
#>
function Show-CompleteNotification 
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$True)]
    [string]$Title,

    [Parameter(Mandatory=$True)]
    [string]$Text,

    [Parameter(Mandatory=$True)]
    [string]$OpenPath,

    [ValidateSet('None', 'Info', 'Warning', 'Error')]
    $Icon = 'Info',

    $Timeout = 10000
  )
 

  function Register-CloseEvent
  {
    [CmdletBinding()]
    Param ( )

    $SOURCE_IDENTIFIER = "notification_close_event"
    # clear any previous events
    Remove-Event $SOURCE_IDENTIFIER -ea SilentlyContinue

    $onCloseAction = 
    {
      $notification = $Sender
      $sourceIdentifier = $Event.SourceIdentifier

      Remove-Event $sourceIdentifier -ea SilentlyContinue
      $notification.Dispose()
      RV –Name 'notification' –Scope 'script'
      Unregister-Event -SourceIdentifier $sourceIdentifier -ea SilentlyContinue
    }

    $registerParams = @{
      InputObject = $Notification;
      EventName = 'BalloonTipClosed';
      SourceIdentifier= $SOURCE_IDENTIFIER;
      Action = $onCloseAction;
    }

    $eventJob = Register-ObjectEvent @registerParams
  }

  function Register-ClickEvent
  {
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory=$True)]
      [string]$OpenPath
    )

    $SOURCE_IDENTIFIER = "notification_click_event"
    # clear any previous events
    Remove-Event $SOURCE_IDENTIFIER -ea SilentlyContinue

    $onClickAction = 
    {
      $openPath = $Event.MessageData

      $notification = $Sender
      $sourceIdentifier = $Event.SourceIdentifier

      #explorer $openPath
      # For some reason explorer cannpt be launched from event handler
      # when script is run through powershell.exe
      Invoke-Item $openPath

      Remove-Event $sourceIdentifier -ea SilentlyContinue
      $notification.Dispose()
      RV –Name 'notification' –Scope 'script'
      Unregister-Event -SourceIdentifier $sourceIdentifier -ea SilentlyContinue
    }

    $registerParams = @{
      InputObject = $Notification;
      EventName = 'BalloonTipClicked';
      SourceIdentifier= $SOURCE_IDENTIFIER;
      Action = $onClickAction;
      MessageData = $OpenPath
    }

    $eventJob = Register-ObjectEvent @registerParams
  }


  Add-Type -AssemblyName System.Windows.Forms

  # clear any previous events
  if($script:notification -ne $Null)
  {
    RV –Name 'notification' –Scope 'script'
  }
  
  Unregister-Event -SourceIdentifier "notification_click_event" -ea SilentlyContinue
  Unregister-Event -SourceIdentifier "notification_close_event" -ea SilentlyContinue

  # create new NotifyIcon only when there is no existing one
  if($script:notification -eq $Null)
  {
    $script:notification = New-Object System.Windows.Forms.NotifyIcon
  }

  # sytem icon - [System.Drawing.SystemIcons]::Information
  $notification.Icon =  "$PSScriptRoot\complete-icon.ico"
  $notification.BalloonTipIcon = $Icon
  $notification.BalloonTipText = $Text
  $notification.BalloonTipTitle = $Title
  $notification.Visible = $True

  Register-ClickEvent $OpenPath
  Register-CloseEvent
  
  $notification.ShowBalloonTip($Timeout)
}

#Show-CompleteNotification "Title" "Text" "C:\tmp\convert_result"