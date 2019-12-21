function Prompt {
    $c = [char]27;
    $reset = "$c[0m";
    # Split current path to extract directory
    $loc = (Get-Location).Path.Replace("\", "/").Split(":");
    # Create some fancy unicode characters
    $pipe = [char]0x2502;
    $ang = [char]0x2514;
    $arr = [char]0x2192;
    $block_arr_left = [char]0x25C0;
    $block_arr_right = [char]0x25B6;
    # Set terminal title
    $host.ui.RawUI.WindowTitle = $loc[1];
    # Get current branch (if any, and redirect errors to $null)
    $gitBranch = & git rev-parse --abbrev-ref HEAD 2>$null
    $gitPrompt = ""
    # If we have a current branch
    if ($gitBranch) {
        # Get status for current branch
        $gitStatus = & git status -s --porcelain
        # Get number of commits behind and after remote
        $gitAheadBehind = & git for-each-ref --format="%(push:track)" refs/heads/$gitBranch
        # If we have a status
        if ($gitStatus) {
            # Create string delimited by ,
            $gitStatus = "$block_arr_left" + [String]::Join(", ", ($gitStatus | 
                    ForEach-Object { 
                        $_.substring(0, 3).trim() # Grab the first 3 characters and remove any whitespace
                    } | 
                    Group-Object | # Group rows
                    ForEach-Object { 
                        "$($_.Count) $($_.Name)" # Transform strings
                    })) + "$block_arr_right"
        }

        # Compile git prompt
        $gitPrompt = "$pipe[Git][$c[42m$c[30m$($gitBranch)$($gitAheadBehind)$($gitStatus)$reset]`r`n"
    }
    "$reset$pipe[$($loc[0])] $($loc[1])`r`n$gitPrompt$reset$ang$arr$reset"
}

Set-Alias -Name nvim -Value C:\tools\neovim\Neovim\bin\nvim-qt.exe

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
