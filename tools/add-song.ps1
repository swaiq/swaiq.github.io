param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$Name = 'song',
    [int]$MaxSeconds = 0
)

$root = Split-Path -Parent $PSScriptRoot
$media = Join-Path $root 'media'
New-Item -ItemType Directory -Force -Path $media | Out-Null
$out = Join-Path $media "$Name.mp3"

$yt = 'yt-dlp'
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    $candidate = Join-Path $env:LOCALAPPDATA 'Python\pythoncore-3.14-64\Scripts\yt-dlp.exe'
    if (Test-Path $candidate) { $yt = $candidate } else {
        Write-Host "yt-dlp غير مثبّت. ثبّته: winget install yt-dlp.yt-dlp" -ForegroundColor Red
        exit 1
    }
}

$args = @('-x', '--audio-format', 'mp3', '--audio-quality', '5', '--no-playlist', '--no-warnings', '-o', $out)
if ($MaxSeconds -gt 0) { $args += @('--download-sections', "*0-$MaxSeconds", '--force-keyframes-at-cuts') }
$args += $Url

Write-Host "· تنزيل الصوت…" -ForegroundColor Cyan
& $yt @args

if (Test-Path $out) {
    $mb = [math]::Round((Get-Item $out).Length / 1MB, 2)
    Write-Host ""
    Write-Host "تم إنشاء: media/$Name.mp3  ($mb MB)" -ForegroundColor Green
    Write-Host "اكتب هذا المسار في محرر الدعوة → «ملف صوتي»:  media/$Name.mp3" -ForegroundColor Yellow
    Write-Host "ثم ارفع مجلد media مع بقية الملفات إلى GitHub." -ForegroundColor Gray
}
else {
    Write-Host "فشل التنزيل." -ForegroundColor Red
}
