Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$f = New-Object Windows.Forms.Form
$f.WindowState = 'Maximized'
$f.FormBorderStyle = 'None'
$f.BackColor = 'Black'
$f.Topmost = $true

$chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&*<>{}[]|/\!?".ToCharArray()
$rng = New-Object Random

$pb = New-Object Windows.Forms.PictureBox
$pb.Dock = 'Fill'
$pb.BackColor = 'Black'
$f.Controls.Add($pb)

$script:bmp = $null
$script:gfx = $null
$script:drops = @()
$script:cols = 0
$script:colW = 16
$script:frame = 0
$script:msgLines = @()
$script:nextMsg = 0
$script:glitchActive = $false
$script:glitchFramesLeft = 0
$script:glitchOX = 0
$script:glitchOY = 0
$script:glitchPhase = 0

$script:msgPool = @(
    "[SYS]  Initiating breach protocol...",
    "[NET]  Bypassing firewall...              SUCCESS",
    "[AUTH] Cracking password hash...          DONE",
    "[FS]   Mounting remote filesystem...",
    "[DATA] Exfiltrating credentials...",
    "[SEC]  Disabling antivirus...             OK",
    "[NET]  Routing through 14 proxy chains...",
    "[SYS]  Kernel exploit injected",
    "[AUTH] ROOT ACCESS GRANTED",
    "[!!!]  SYSTEM FULLY COMPROMISED"
)

$matrixFont = New-Object Drawing.Font("Courier New", 13, [Drawing.FontStyle]::Bold)
$mainFont   = New-Object Drawing.Font("Courier New", 48, [Drawing.FontStyle]::Bold)
$subFont    = New-Object Drawing.Font("Courier New", 26, [Drawing.FontStyle]::Bold)
$hackFont   = New-Object Drawing.Font("Courier New", 11)

$pb.Add_Paint({ if ($script:bmp) { $_.Graphics.DrawImage($script:bmp, 0, 0) } })

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 40

$timer.Add_Tick({
    $w = $pb.Width; $h = $pb.Height
    if ($w -le 0 -or $h -le 0) { return }

    if (-not $script:bmp -or $script:bmp.Width -ne $w -or $script:bmp.Height -ne $h) {
        if ($script:bmp) { $script:bmp.Dispose(); $script:gfx.Dispose() }
        $script:bmp  = New-Object Drawing.Bitmap($w, $h)
        $script:gfx  = [Drawing.Graphics]::FromImage($script:bmp)
        $script:gfx.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAlias
        $script:cols = [Math]::Floor($w / $script:colW)
        $script:drops = 0..($script:cols - 1) | ForEach-Object { $rng.Next(-40, 0) }
    }

    $g = $script:gfx

    if (-not $script:glitchActive) {
        if ($rng.Next(100) -lt 3) {
            $script:glitchActive     = $true
            $script:glitchFramesLeft = $rng.Next(2, 4)   # ← FIXED: was (2,7)
            $diag = $rng.Next(4, 14)
            $sign = if ($rng.Next(2) -eq 0) { 1 } else { -1 }
            $script:glitchOX = $diag * $sign
            $script:glitchOY = $diag * $sign * (if ($rng.Next(2) -eq 0) { 1 } else { -1 })
            $script:glitchPhase = $rng.Next(1, 4)
        }
    } else {
        $script:glitchFramesLeft--
        if ($script:glitchFramesLeft -le 0) {
            $script:glitchActive = $false
            $script:glitchOX = 0
            $script:glitchOY = 0
        }
    }

    $fade = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(18, 0, 0, 0))
    $g.FillRectangle($fade, 0, 0, $w, $h)
    $fade.Dispose()

    for ($i = 0; $i -lt $script:cols; $i++) {
        $char = [string]$chars[$rng.Next($chars.Length)]
        $x = $i * $script:colW
        $y = $script:drops[$i] * $script:colW
        $alpha = $rng.Next(30, 110)
        $hb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb($alpha, 30, 180, 60))
        $g.DrawString($char, $matrixFont, $hb, $x, $y)
        $hb.Dispose()
        if ($y -gt $h -and $rng.Next(100) -lt 5) {
            $script:drops[$i] = $rng.Next(-30, 0)
        } else {
            $script:drops[$i]++
        }
    }

    $title  = "You have been hacked..."
    $author = "- Winters"

    $tsz = $g.MeasureString($title, $mainFont)
    $asz = $g.MeasureString($author, $subFont)
    $totalH = $tsz.Height + 14 + $asz.Height
    $tx = ($w - $tsz.Width) / 2
    $ty = ($h - $totalH) / 2 - 20
    $ax = ($w - $asz.Width) / 2
    $ay = $ty + $tsz.Height + 14
    $gx = $tx + $script:glitchOX
    $gy = $ty + $script:glitchOY
    $gax = $ax + $script:glitchOX
    $gay = $ay + $script:glitchOY

    if ($script:glitchActive) {
        if ($script:glitchPhase -eq 1) {
            $rb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(80, 255, 30, 30))
            $bb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(80, 30, 80, 255))
            $g.DrawString($title, $mainFont, $rb, ($gx - 5), ($gy - 5))
            $g.DrawString($title, $mainFont, $bb, ($gx + 5), ($gy + 5))
            $g.DrawString($author, $subFont, $rb, ($gax - 5), ($gay - 5))
            $g.DrawString($author, $subFont, $bb, ($gax + 5), ($gay + 5))
            $rb.Dispose(); $bb.Dispose()
        }
        if ($script:glitchPhase -eq 2) {
            $ghost = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(35, 0, 230, 80))
            $g.DrawString($title, $mainFont, $ghost, $tx, $ty)
            $g.DrawString($author, $subFont, $ghost, $ax, $ay)
            $ghost.Dispose()
        }
        if ($script:glitchPhase -eq 3) {
            $d1 = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(50, 0, 255, 100))
            $d2 = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(40, 180, 255, 80))
            $g.DrawString($title, $mainFont, $d1, ($tx - 8), ($ty + 3))
            $g.DrawString($title, $mainFont, $d2, ($tx + 6), ($ty - 4))
            $g.DrawString($author, $subFont, $d1, ($ax - 8), ($ay + 3))
            $g.DrawString($author, $subFont, $d2, ($ax + 6), ($ay - 4))
            $d1.Dispose(); $d2.Dispose()
        }
    }

    $ob = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 0, 0, 0))
    foreach ($ox in @(-2, 0, 2)) {
        foreach ($oy in @(-2, 0, 2)) {
            if ($ox -ne 0 -or $oy -ne 0) {
                $g.DrawString($title,  $mainFont, $ob, ($gx + $ox), ($gy + $oy))
                $g.DrawString($author, $subFont,  $ob, ($gax + $ox), ($gay + $oy))
            }
        }
    }
    $ob.Dispose()

    $glw = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(50, 0, 255, 80))
    $g.DrawString($title,  $mainFont, $glw, ($gx - 3), ($gy - 3))
    $g.DrawString($title,  $mainFont, $glw, ($gx + 3), ($gy + 3))
    $g.DrawString($author, $subFont,  $glw, ($gax - 3), ($gay - 3))
    $g.DrawString($author, $subFont,  $glw, ($gax + 3), ($gay + 3))
    $glw.Dispose()

    $tb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 0, 230, 80))
    $g.DrawString($title,  $mainFont, $tb, $gx, $gy)
    $g.DrawString($author, $subFont,  $tb, $gax, $gay)
    $tb.Dispose()
	
    $padX = 40; $padY = 20
    $lb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(160, 0, 210, 70))
    $g.FillRectangle($lb, ($gx - $padX), ($gy - $padY), ($tsz.Width + $padX * 2), 1)
    $g.FillRectangle($lb, ($gx - $padX), ($gay + $asz.Height + $padY), ($tsz.Width + $padX * 2), 1)
    $lb.Dispose()

    if ($script:frame % 38 -eq 0 -and $script:nextMsg -lt $script:msgPool.Count) {
        $script:msgLines += $script:msgPool[$script:nextMsg]
        $script:nextMsg++
        if ($script:msgLines.Count -gt 10) {
            $script:msgLines = $script:msgLines[1..($script:msgLines.Count - 1)]
        }
    }

    $msgY = $h - 220
    foreach ($msg in $script:msgLines) {
        $mc = if ($msg -match "SUCCESS|DONE|GRANTED|OK") {
            [Drawing.Color]::FromArgb(220, 0, 220, 100)
        } elseif ($msg -match "\[!!!\]|COMPROMISED") {
            [Drawing.Color]::FromArgb(255, 255, 60, 60)
        } else {
            [Drawing.Color]::FromArgb(200, 0, 190, 75)
        }
        $msgB = New-Object Drawing.SolidBrush($mc)
        $g.DrawString($msg, $hackFont, $msgB, 50, $msgY)
        $msgB.Dispose()
        $msgY += 18
    }

    if ($script:msgLines.Count -gt 0 -and ([Math]::Floor($script:frame / 12) % 2 -eq 0)) {
        $cb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(220, 0, 220, 80))
        $g.DrawString("_", $hackFont, $cb, 50, $msgY)
        $cb.Dispose()
    }

    $pb.Invalidate()
    $script:frame++
})

$timer.Start()
[void]$f.ShowDialog()
$timer.Stop()
if ($script:bmp) { $script:bmp.Dispose(); $script:gfx.Dispose() }
