function ansi ([int] $code) {
    $c = [char]27;
    "$c[$($code)m"
}

function Prompt {
    $colors = @{
        reset    = ansi(0)
        bgblack  = ansi(40)
        bgblue   = ansi(44)
        bggreen  = ansi(42)
        bgwhite  = ansi(47)
        bgyellow = ansi(43)
        fgblack  = ansi(30)
        fgblue   = ansi(34)
        fggreen  = ansi(32)
        fgwhite  = ansi(37)
        fgyellow = ansi(33)
    }
    # Split current path to extract directory
    $loc = (Get-Location).Path.Replace("\", "/").Split(":")
    if ((Get-Location).Path -eq $HOME) {
        $loc[1] = "~"
    }
    # Create some fancy unicode characters
    $seg = [char]0xE0B0;
    $branchSymbol = [char]0xe0a0;
    $ahead = [char]0x21e1;
    $behind = [char]0x21e3;

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
        $gitAheadBehind = ((& git for-each-ref --format="%(push:track)" refs/heads/$gitBranch) -replace "ahead ", $ahead) -replace "behind ", $behind

        # If we have a status
        if ($gitStatus) {
            # Create string delimited by ,
            $gitStatus = [String]::Join(", ", ($gitStatus | 
                    ForEach-Object { 
                        $_.substring(0, 3).trim() # Grab the first 3 characters and remove any whitespace
                    } | 
                    Group-Object | # Group rows
                    ForEach-Object { 
                        "$($_.Count) $($_.Name)" # Transform strings
                    }))
        }

        # Compile git prompt
        $gitPrompt = -join (@(
                { $colors.fgwhite }
                { $colors.bgblue }
                { " " }
                { $branchSymbol } 
                { " " }
                { $gitBranch } 
                { if ($gitAheadBehind) { " " } else { "" } }
                { $gitAheadBehind } 
                { " " }
                { $gitStatus }
                { " " }
                { $colors.fgblue }
                { $colors.bgblack }
                { $seg }
            )).invoke()
    }
    $prompt = @(
        { $colors.bgyellow }
        { $colors.fgblack }
        { " " }
        { $loc[0] }
        { " $([char]0x205D) " }
        { $loc[1] }
        { " " }
        { $colors.fgyellow }
        { if ($gitBranch) { $colors.bgblue } else { $colors.bgblack } }
        { $seg }
        { $colors.fgwhite }
        { $gitPrompt }
        { $colors.reset }
        { [System.Environment]::NewLine }
        { $colors.fgblue }
        { " > " }
    )
    -join $prompt.invoke()
}

Set-Alias -Name nvim -Value C:\tools\neovim\Neovim\bin\nvim-qt.exe

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
