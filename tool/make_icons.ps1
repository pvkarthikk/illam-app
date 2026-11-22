Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile("$root\assets\fonts\YoungSerif-Regular.ttf")
New-Item -ItemType Directory -Force "$root\assets\icon" | Out-Null
function Make-Icon([string]$path, [string]$bg, [string]$fg, [int]$px) {
  $bmp = New-Object System.Drawing.Bitmap 1024, 1024
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAlias'
  if ($bg) { $g.Clear([System.Drawing.ColorTranslator]::FromHtml($bg)) } else { $g.Clear([System.Drawing.Color]::Transparent) }
  $font = New-Object System.Drawing.Font($fonts.Families[0], $px, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($fg))
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
  $g.TranslateTransform(512, 530); $g.RotateTransform(-6)
  $g.DrawString('N', $font, $brush, (New-Object System.Drawing.RectangleF(-512, -512, 1024, 1024)), $fmt)
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}
Make-Icon "$root\assets\icon\icon.png" '#D98F1C' '#1B140A' 640
Make-Icon "$root\assets\icon\icon_fg.png" $null '#1B140A' 430
Make-Icon "$root\assets\icon\icon_mono.png" $null '#FFFFFF' 430
