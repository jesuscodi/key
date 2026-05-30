# ============================================================
#   SysCodi WinTool Pro v2.0
#   Mejoras: Admin check, async, progress bar, tooltips,
#   confirmaciones, nuevas funciones, pestaña Servicios
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
#   VERIFICAR ADMINISTRADOR
# ============================================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $r = [Windows.Forms.MessageBox]::Show(
        "Este programa requiere privilegios de Administrador para funcionar correctamente.`n`n¿Deseas reiniciarlo como Administrador?",
        "Permisos insuficientes",
        [Windows.Forms.MessageBoxButtons]::YesNo,
        [Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($r -eq "Yes") {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    exit
}

# ============================================================
#   VERIFICAR WINGET
# ============================================================
$wingetOk = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)

# ============================================================
#   LOGO - Descarga desde GitHub
# ============================================================
$logoUrl  = "https://raw.githubusercontent.com/syscodi7/Tools/main/sis.png"
$logoPath = "$env:TEMP\syscodi_logo.png"
try { Invoke-WebRequest -Uri $logoUrl -OutFile $logoPath -ErrorAction Stop } catch { $logoPath = $null }

# ============================================================
#   COLORES CORPORATIVOS
# ============================================================
$cBg      = [Drawing.Color]::FromArgb(15, 25, 50)
$cPanel   = [Drawing.Color]::FromArgb(22, 38, 75)
$cCard    = [Drawing.Color]::FromArgb(30, 50, 100)
$cAccent  = [Drawing.Color]::FromArgb(0, 120, 215)
$cAccent2 = [Drawing.Color]::FromArgb(0, 180, 255)
$cText    = [Drawing.Color]::White
$cSubText = [Drawing.Color]::FromArgb(160, 200, 255)
$cBtn     = [Drawing.Color]::FromArgb(0, 100, 180)
$cBtnWarn = [Drawing.Color]::FromArgb(150, 100, 0)
$cBtnDang = [Drawing.Color]::FromArgb(140, 30, 30)
$cBtnGood = [Drawing.Color]::FromArgb(20, 100, 30)
$cOutput  = [Drawing.Color]::FromArgb(10, 18, 40)
$cBorder  = [Drawing.Color]::FromArgb(0, 120, 215)

# ============================================================
#   FORMULARIO PRINCIPAL
# ============================================================
$form = New-Object Windows.Forms.Form
$form.Text = "SysCodi WinTool Pro v2"
$form.Size = New-Object Drawing.Size(1240, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = $cBg
$form.ForeColor = $cText
$form.Font = New-Object Drawing.Font("Segoe UI", 9)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# ============================================================
#   HEADER
# ============================================================
$header = New-Object Windows.Forms.Panel
$header.Size = New-Object Drawing.Size(1240, 62)
$header.Location = New-Object Drawing.Point(0, 0)
$header.BackColor = $cPanel
$form.Controls.Add($header)
$header.BringToFront()

if ($logoPath -and (Test-Path $logoPath)) {
    $logoPic = New-Object Windows.Forms.PictureBox
    $logoPic.Location = New-Object Drawing.Point(10, 5)
    $logoPic.Size = New-Object Drawing.Size(50, 50)
    $logoPic.SizeMode = "Zoom"
    $logoPic.BackColor = $cPanel
    $logoPic.Image = [Drawing.Image]::FromFile($logoPath)
    $header.Controls.Add($logoPic)
    try {
        $bmp  = [Drawing.Bitmap][Drawing.Image]::FromFile($logoPath)
        $icon = [Drawing.Icon]::FromHandle($bmp.GetHicon())
        $form.Icon = $icon
    } catch {}
    $titleX = 70
} else { $titleX = 15 }

$lblTitle = New-Object Windows.Forms.Label
$lblTitle.Text = "SysCodi WinTool Pro"
$lblTitle.Font = New-Object Drawing.Font("Segoe UI", 14, [Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $cAccent2
$lblTitle.Location = New-Object Drawing.Point($titleX, 8)
$lblTitle.Size = New-Object Drawing.Size(420, 30)
$header.Controls.Add($lblTitle)

$lblSub = New-Object Windows.Forms.Label
$lblSub.Text = "Utilidad de sistema avanzada para Windows"
$lblSub.Font = New-Object Drawing.Font("Segoe UI", 8)
$lblSub.ForeColor = $cSubText
$lblSub.Location = New-Object Drawing.Point($titleX, 40)
$lblSub.Size = New-Object Drawing.Size(420, 16)
$header.Controls.Add($lblSub)

# Badge Administrador
$lblAdmin = New-Object Windows.Forms.Label
$lblAdmin.Text = if ($isAdmin) { "  Administrador" } else { "  Usuario Limitado" }
$lblAdmin.Font = New-Object Drawing.Font("Segoe UI", 8, [Drawing.FontStyle]::Bold)
$lblAdmin.ForeColor = if ($isAdmin) { [Drawing.Color]::LightGreen } else { [Drawing.Color]::Salmon }
$lblAdmin.BackColor = if ($isAdmin) { [Drawing.Color]::FromArgb(20, 60, 20) } else { [Drawing.Color]::FromArgb(60, 20, 20) }
$lblAdmin.Location = New-Object Drawing.Point(1060, 20)
$lblAdmin.Size = New-Object Drawing.Size(155, 24)
$lblAdmin.TextAlign = "MiddleCenter"
$header.Controls.Add($lblAdmin)

# ============================================================
#   BARRA DE PROGRESO GLOBAL
# ============================================================
$progressBar = New-Object Windows.Forms.ProgressBar
$progressBar.Location = New-Object Drawing.Point(5, 63)
$progressBar.Size = New-Object Drawing.Size(740, 5)
$progressBar.Style = "Marquee"
$progressBar.MarqueeAnimationSpeed = 0
$progressBar.BackColor = $cPanel
$form.Controls.Add($progressBar)

function Start-Progress { $progressBar.MarqueeAnimationSpeed = 30; $form.Refresh() }
function Stop-Progress  { $progressBar.MarqueeAnimationSpeed = 0;  $form.Refresh() }

# ============================================================
#   TOOLTIP GLOBAL
# ============================================================
$tip = New-Object Windows.Forms.ToolTip
$tip.AutoPopDelay = 5000
$tip.InitialDelay = 600
$tip.ReshowDelay  = 500
$tip.ShowAlways   = $true

# ============================================================
#   TAB CONTROL
# ============================================================
$tabs = New-Object Windows.Forms.TabControl
$tabs.Location = New-Object Drawing.Point(5, 70)
$tabs.Size = New-Object Drawing.Size(748, 560)
$tabs.BackColor = $cBg
$tabs.Appearance = "FlatButtons"
$tabs.Font = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
$form.Controls.Add($tabs)

function New-Tab($titulo) {
    $t = New-Object Windows.Forms.TabPage
    $t.Text = "  $titulo  "
    $t.BackColor = $cBg
    $t.ForeColor = $cText
    $tabs.TabPages.Add($t)
    return $t
}

$tabRepair   = New-Tab "Reparación"
$tabApps     = New-Tab "Aplicaciones"
$tabTweaks   = New-Tab "Tweaks"
$tabUtils    = New-Tab "Utilidades"
$tabServices = New-Tab "Servicios"
$tabInfo     = New-Tab "Sistema"

# ============================================================
#   PANEL DERECHO - CONSOLA
# ============================================================
$rightPanel = New-Object Windows.Forms.Panel
$rightPanel.Location = New-Object Drawing.Point(756, 70)
$rightPanel.Size = New-Object Drawing.Size(468, 560)
$rightPanel.BackColor = $cOutput
$form.Controls.Add($rightPanel)

$lblConsole = New-Object Windows.Forms.Label
$lblConsole.Text = "  Consola de salida"
$lblConsole.Location = New-Object Drawing.Point(0, 0)
$lblConsole.Size = New-Object Drawing.Size(468, 28)
$lblConsole.ForeColor = $cAccent2
$lblConsole.BackColor = $cPanel
$lblConsole.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$lblConsole.TextAlign = "MiddleLeft"
$rightPanel.Controls.Add($lblConsole)

$btnClearOutput = New-Object Windows.Forms.Button
$btnClearOutput.Text = "Limpiar"
$btnClearOutput.Location = New-Object Drawing.Point(310, 3)
$btnClearOutput.Size = New-Object Drawing.Size(70, 22)
$btnClearOutput.BackColor = $cBtn
$btnClearOutput.ForeColor = $cText
$btnClearOutput.FlatStyle = "Flat"
$btnClearOutput.Font = New-Object Drawing.Font("Segoe UI", 7)
$btnClearOutput.Add_Click({ $outputBox.Clear(); $outputBox.AppendText("  Consola limpiada.") })
$rightPanel.Controls.Add($btnClearOutput)

$btnExportLog = New-Object Windows.Forms.Button
$btnExportLog.Text = "Exportar Log"
$btnExportLog.Location = New-Object Drawing.Point(385, 3)
$btnExportLog.Size = New-Object Drawing.Size(78, 22)
$btnExportLog.BackColor = $cBtnGood
$btnExportLog.ForeColor = $cText
$btnExportLog.FlatStyle = "Flat"
$btnExportLog.Font = New-Object Drawing.Font("Segoe UI", 7)
$btnExportLog.Add_Click({
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = "$env:USERPROFILE\Desktop\SysCodi_Log_$ts.txt"
    $outputBox.Text | Set-Content $logFile -Encoding UTF8
    Write-Out "Log guardado en: $logFile" ([Drawing.Color]::LightGreen)
})
$rightPanel.Controls.Add($btnExportLog)

$tip.SetToolTip($btnExportLog, "Guarda toda la consola en un .txt en tu Escritorio")

$outputBox = New-Object Windows.Forms.RichTextBox
$outputBox.Location = New-Object Drawing.Point(0, 30)
$outputBox.Size = New-Object Drawing.Size(468, 530)
$outputBox.BackColor = $cOutput
$outputBox.ForeColor = $cAccent2
$outputBox.Font = New-Object Drawing.Font("Consolas", 9)
$outputBox.ReadOnly = $true
$outputBox.BorderStyle = "None"
$outputBox.Text = "  Listo. Selecciona una opción y ejecuta."
$rightPanel.Controls.Add($outputBox)

function Write-Out($msg, $color = $null) {
    $outputBox.SelectionStart = $outputBox.TextLength
    if ($color) { $outputBox.SelectionColor = $color }
    else { $outputBox.SelectionColor = $cAccent2 }
    $outputBox.AppendText("`r`n $msg")
    $outputBox.ScrollToCaret()
}

function Run-Cmd($cmd) {
    Write-Out "Ejecutando: $cmd" $cSubText
    Start-Progress
    try {
        $res = Invoke-Expression $cmd 2>&1
        Write-Out ($res -join "`r`n") $cText
    } catch {
        Write-Out "Error: $_" ([Drawing.Color]::Salmon)
    }
    Stop-Progress
}

function Confirm-Action($msg) {
    $r = [Windows.Forms.MessageBox]::Show($msg, "Confirmar acción", "YesNo", "Warning")
    return ($r -eq "Yes")
}

# ============================================================
#   HELPER: botones
# ============================================================
function New-Btn($texto, $x, $y, $w=210, $h=34, $style="normal") {
    $b = New-Object Windows.Forms.Button
    $b.Text = $texto
    $b.Location = New-Object Drawing.Point($x, $y)
    $b.Size = New-Object Drawing.Size($w, $h)
    $b.ForeColor = $cText
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderSize = 1
    $b.Font = New-Object Drawing.Font("Segoe UI", 9)
    $b.Cursor = "Hand"
    switch ($style) {
        "warn"   { $b.BackColor = $cBtnWarn; $b.FlatAppearance.BorderColor = [Drawing.Color]::Orange }
        "danger" { $b.BackColor = $cBtnDang; $b.FlatAppearance.BorderColor = [Drawing.Color]::Salmon }
        "good"   { $b.BackColor = $cBtnGood; $b.FlatAppearance.BorderColor = [Drawing.Color]::LightGreen }
        default  { $b.BackColor = $cBtn;     $b.FlatAppearance.BorderColor = $cAccent }
    }
    return $b
}

function New-SectionLabel($texto, $x, $y, $parent) {
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $texto
    $lbl.Location = New-Object Drawing.Point($x, $y)
    $lbl.Size = New-Object Drawing.Size(880, 22)
    $lbl.ForeColor = $cAccent2
    $lbl.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $parent.Controls.Add($lbl)
}

# ============================================================
#   TAB 1: REPARACIÓN
# ============================================================
New-SectionLabel "  Limpieza" 10 10 $tabRepair

$btnLimpiar = New-Btn "Limpiar Temporales" 10 34
$btnLimpiar.Add_Click({
    Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
    Write-Out "Temporales eliminados correctamente." ([Drawing.Color]::LightGreen)
})
$tip.SetToolTip($btnLimpiar, "Elimina archivos en %TEMP% y C:\Windows\Temp")
$tabRepair.Controls.Add($btnLimpiar)

$btnPrefetch = New-Btn "Limpiar Prefetch" 230 34
$btnPrefetch.Add_Click({
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue
    Write-Out "Prefetch limpiado." ([Drawing.Color]::LightGreen)
})
$tip.SetToolTip($btnPrefetch, "Elimina archivos de precarga de programas")
$tabRepair.Controls.Add($btnPrefetch)

$btnPapelera = New-Btn "Vaciar Papelera" 450 34
$btnPapelera.Add_Click({
    if (Confirm-Action "¿Vaciar la Papelera de Reciclaje?") {
        Clear-RecycleBin -Force -EA SilentlyContinue
        Write-Out "Papelera vaciada." ([Drawing.Color]::LightGreen)
    }
})
$tip.SetToolTip($btnPapelera, "Vacía permanentemente la Papelera de Reciclaje")
$tabRepair.Controls.Add($btnPapelera)

New-SectionLabel "  Reparación de Windows" 10 80 $tabRepair

$btnSFC = New-Btn "SFC /scannow" 10 104
$btnSFC.Add_Click({
    Write-Out "Iniciando SFC... (puede tardar varios minutos)" $cSubText
    Start-Progress
    $job = Start-Job { sfc /scannow }
    while ($job.State -eq 'Running') { [Windows.Forms.Application]::DoEvents(); Start-Sleep -Milliseconds 300 }
    $res = Receive-Job $job; Remove-Job $job
    Write-Out ($res -join "`r`n") $cText
    Stop-Progress
})
$tip.SetToolTip($btnSFC, "Escanea y repara archivos del sistema de Windows")
$tabRepair.Controls.Add($btnSFC)

$btnDISM = New-Btn "DISM RestoreHealth" 230 104
$btnDISM.Add_Click({
    Write-Out "Iniciando DISM... (puede tardar varios minutos)" $cSubText
    Start-Progress
    $job = Start-Job { DISM /Online /Cleanup-Image /RestoreHealth }
    while ($job.State -eq 'Running') { [Windows.Forms.Application]::DoEvents(); Start-Sleep -Milliseconds 300 }
    $res = Receive-Job $job; Remove-Job $job
    Write-Out ($res -join "`r`n") $cText
    Stop-Progress
})
$tip.SetToolTip($btnDISM, "Repara la imagen de Windows usando Windows Update")
$tabRepair.Controls.Add($btnDISM)

$btnChkDsk = New-Btn "CheckDisk (C:)" 450 104 210 34 "warn"
$btnChkDsk.Add_Click({
    if (Confirm-Action "CheckDisk requiere reinicio para ejecutarse en C:. ¿Programarlo para el siguiente inicio?") {
        Run-Cmd "chkdsk C: /f /r /x"
        Write-Out "CheckDisk programado. Reinicia el equipo para ejecutarlo." ([Drawing.Color]::Yellow)
    }
})
$tip.SetToolTip($btnChkDsk, "Verifica y repara errores en el disco C: (requiere reinicio)")
$tabRepair.Controls.Add($btnChkDsk)

New-SectionLabel "  Red" 10 150 $tabRepair

$btnDNS = New-Btn "DNS Flush" 10 174
$btnDNS.Add_Click({ Run-Cmd "ipconfig /flushdns" })
$tip.SetToolTip($btnDNS, "Limpia la caché de resolución DNS")
$tabRepair.Controls.Add($btnDNS)

$btnNetReset = New-Btn "Reset Red (netsh)" 230 174 210 34 "warn"
$btnNetReset.Add_Click({
    if (Confirm-Action "Esto restablecerá la configuración de red. ¿Continuar?") {
        Run-Cmd "netsh int ip reset"
        Run-Cmd "netsh winsock reset"
        Write-Out "Reinicia el PC para aplicar los cambios de red." ([Drawing.Color]::Yellow)
    }
})
$tip.SetToolTip($btnNetReset, "Restablece configuración IP y Winsock (requiere reinicio)")
$tabRepair.Controls.Add($btnNetReset)

$btnPuertos = New-Btn "Ver Puertos Abiertos" 450 174
$btnPuertos.Add_Click({ Run-Cmd "netstat -ano" })
$tip.SetToolTip($btnPuertos, "Muestra todos los puertos en uso con su PID")
$tabRepair.Controls.Add($btnPuertos)

# Ping / Traceroute con campo de texto
$lblPingHost = New-Object Windows.Forms.Label
$lblPingHost.Text = "Host:"
$lblPingHost.Location = New-Object Drawing.Point(12, 220)
$lblPingHost.Size = New-Object Drawing.Size(35, 22)
$lblPingHost.ForeColor = $cSubText
$tabRepair.Controls.Add($lblPingHost)

$txtPingHost = New-Object Windows.Forms.TextBox
$txtPingHost.Location = New-Object Drawing.Point(50, 218)
$txtPingHost.Size = New-Object Drawing.Size(160, 24)
$txtPingHost.BackColor = [Drawing.Color]::FromArgb(10,18,40)
$txtPingHost.ForeColor = $cText
$txtPingHost.Text = "8.8.8.8"
$tabRepair.Controls.Add($txtPingHost)

$btnPing = New-Btn "Ping" 220 216 100 28
$btnPing.Add_Click({
    $h = $txtPingHost.Text.Trim()
    if ($h -eq "") { Write-Out "Ingresa un host para hacer ping." ([Drawing.Color]::Yellow); return }
    Run-Cmd "ping -n 4 $h"
})
$tip.SetToolTip($btnPing, "Envía 4 paquetes ICMP al host especificado")
$tabRepair.Controls.Add($btnPing)

$btnTrace = New-Btn "Traceroute" 330 216 120 28
$btnTrace.Add_Click({
    $h = $txtPingHost.Text.Trim()
    if ($h -eq "") { Write-Out "Ingresa un host para traceroute." ([Drawing.Color]::Yellow); return }
    Run-Cmd "tracert $h"
})
$tip.SetToolTip($btnTrace, "Traza la ruta de red hasta el host especificado")
$tabRepair.Controls.Add($btnTrace)

$btnKill80 = New-Btn "Matar Puerto 80" 460 216 180 28 "danger"
$btnKill80.Add_Click({
    if (Confirm-Action "¿Terminar todos los procesos usando el puerto 80?") {
        $pids = (netstat -ano | Select-String ":80\s") -replace '.*\s(\d+)$','$1' | Sort-Object -Unique
        foreach ($p in $pids) {
            if ($p -match '^\d+$') {
                Stop-Process -Id $p -Force -EA SilentlyContinue
                Write-Out "Proceso PID $p en puerto 80 terminado." ([Drawing.Color]::LightGreen)
            }
        }
    }
})
$tip.SetToolTip($btnKill80, "Mata todos los procesos que usan el puerto 80")
$tabRepair.Controls.Add($btnKill80)

New-SectionLabel "  Seguridad y Sistema" 10 258 $tabRepair

$btnDefender = New-Btn "Escanear con Defender" 10 282 230 34 "good"
$btnDefender.Add_Click({
    Write-Out "Iniciando escaneo rápido de Windows Defender..." $cSubText
    Start-Process "C:\Program Files\Windows Defender\MpCmdRun.exe" -ArgumentList "-Scan -ScanType 1" -Wait -WindowStyle Hidden
    Write-Out "Escaneo completado." ([Drawing.Color]::LightGreen)
})
$tip.SetToolTip($btnDefender, "Ejecuta un escaneo rápido con Windows Defender")
$tabRepair.Controls.Add($btnDefender)

$btnRestorePoint = New-Btn "Crear Punto Restauración" 250 282 240 34 "good"
$btnRestorePoint.Add_Click({
    $desc = "SysCodi_$(Get-Date -Format 'yyyyMMdd_HHmm')"
    try {
        Enable-ComputerRestore -Drive "C:\" -EA SilentlyContinue
        Checkpoint-Computer -Description $desc -RestorePointType "MODIFY_SETTINGS" -EA Stop
        Write-Out "Punto de restauración creado: $desc" ([Drawing.Color]::LightGreen)
    } catch {
        Write-Out "Error al crear punto de restauración: $_" ([Drawing.Color]::Salmon)
    }
})
$tip.SetToolTip($btnRestorePoint, "Crea un punto de restauración del sistema antes de hacer cambios")
$tabRepair.Controls.Add($btnRestorePoint)

$btnReboot = New-Btn "Reiniciar PC" 500 282 150 34 "warn"
$btnReboot.Add_Click({
    if (Confirm-Action "¿Reiniciar el equipo ahora?") {
        Write-Out "Reiniciando..." ([Drawing.Color]::Yellow)
        Start-Sleep -Seconds 2
        Restart-Computer -Force
    }
})
$tip.SetToolTip($btnReboot, "Reinicia el equipo (solicita confirmación)")
$tabRepair.Controls.Add($btnReboot)

# ============================================================
#   TAB 2: APLICACIONES
# ============================================================
if (-not $wingetOk) {
    $lblNoWinget = New-Object Windows.Forms.Label
    $lblNoWinget.Text = "  ADVERTENCIA: WinGet no está instalado. Instálalo desde la Microsoft Store (App Installer) para usar esta pestaña."
    $lblNoWinget.Location = New-Object Drawing.Point(5, 5)
    $lblNoWinget.Size = New-Object Drawing.Size(730, 30)
    $lblNoWinget.ForeColor = [Drawing.Color]::Salmon
    $lblNoWinget.BackColor = [Drawing.Color]::FromArgb(60, 20, 20)
    $lblNoWinget.Font = New-Object Drawing.Font("Segoe UI", 8, [Drawing.FontStyle]::Bold)
    $tabApps.Controls.Add($lblNoWinget)
}

$scroll = New-Object Windows.Forms.Panel
$scroll.Location = New-Object Drawing.Point(0, if ($wingetOk) {0} else {35})
$scroll.Size = New-Object Drawing.Size(740, if ($wingetOk) {455} else {420})
$scroll.AutoScroll = $true
$scroll.BackColor = $cBg
$tabApps.Controls.Add($scroll)

$appList = @(
    @{cat="Navegadores";    name="Google Chrome";    cmd="winget install -e --id Google.Chrome"},
    @{cat="Navegadores";    name="Mozilla Firefox";  cmd="winget install -e --id Mozilla.Firefox"},
    @{cat="Navegadores";    name="Brave Browser";    cmd="winget install -e --id Brave.Brave"; foss=$true},
    @{cat="Navegadores";    name="LibreWolf";         cmd="winget install -e --id LibreWolf.LibreWolf"; foss=$true},
    @{cat="Comunicación";   name="Discord";           cmd="winget install -e --id Discord.Discord"},
    @{cat="Comunicación";   name="Telegram";          cmd="winget install -e --id Telegram.TelegramDesktop"; foss=$true},
    @{cat="Comunicación";   name="Slack";             cmd="winget install -e --id SlackTechnologies.Slack"},
    @{cat="Comunicación";   name="Signal";            cmd="winget install -e --id OpenWhisperSystems.Signal"; foss=$true},
    @{cat="Comunicación";   name="WhatsApp";          cmd="winget install -e --id 9NKSQGP7F2NH"},
    @{cat="Desarrollo";     name="VS Code";           cmd="winget install -e --id Microsoft.VisualStudioCode"},
    @{cat="Desarrollo";     name="Git";               cmd="winget install -e --id Git.Git"; foss=$true},
    @{cat="Desarrollo";     name="Python 3";          cmd="winget install -e --id Python.Python.3"; foss=$true},
    @{cat="Desarrollo";     name="NodeJS LTS";        cmd="winget install -e --id OpenJS.NodeJS.LTS"; foss=$true},
    @{cat="Desarrollo";     name="GitHub Desktop";    cmd="winget install -e --id GitHub.GitHubDesktop"},
    @{cat="Utilidades";     name="7-Zip";             cmd="winget install -e --id 7zip.7zip"; foss=$true},
    @{cat="Utilidades";     name="VLC";               cmd="winget install -e --id VideoLAN.VLC"; foss=$true},
    @{cat="Utilidades";     name="WinRAR";            cmd="winget install -e --id RARLab.WinRAR"},
    @{cat="Utilidades";     name="Notepad++";         cmd="winget install -e --id Notepad++.Notepad++"; foss=$true},
    @{cat="Utilidades";     name="Everything";        cmd="winget install -e --id voidtools.Everything"; foss=$true},
    @{cat="Utilidades";     name="TreeSize Free";     cmd="winget install -e --id JAMSoftware.TreeSize.Free"},
    @{cat="Seguridad";      name="Bitwarden";         cmd="winget install -e --id Bitwarden.Bitwarden"; foss=$true},
    @{cat="Seguridad";      name="Malwarebytes";      cmd="winget install -e --id Malwarebytes.Malwarebytes"},
    @{cat="Multimedia";     name="Spotify";           cmd="winget install -e --id Spotify.Spotify"},
    @{cat="Multimedia";     name="OBS Studio";        cmd="winget install -e --id OBSProject.OBSStudio"; foss=$true},
    @{cat="Multimedia";     name="HandBrake";         cmd="winget install -e --id HandBrake.HandBrake"; foss=$true}
)

$checkboxes = @()
$yPos = 5; $lastCat = ""; $col = 0

foreach ($app in $appList) {
    if ($app.cat -ne $lastCat) {
        $col = 0
        if ($lastCat -ne "") { $yPos += 8 }
        $lbl = New-Object Windows.Forms.Label
        $lbl.Text = "  $($app.cat)"
        $lbl.Location = New-Object Drawing.Point(5, $yPos)
        $lbl.Size = New-Object Drawing.Size(730, 20)
        $lbl.ForeColor = $cAccent2
        $lbl.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
        $scroll.Controls.Add($lbl)
        $yPos += 22
        $lastCat = $app.cat
    }
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $app.name
    $cb.Location = New-Object Drawing.Point((5 + $col * 180), $yPos)
    $cb.Size = New-Object Drawing.Size(172, 22)
    $cb.ForeColor = if ($app.foss) { $cAccent2 } else { $cText }
    $cb.BackColor = $cBg
    $cb.Tag = $app.cmd
    $scroll.Controls.Add($cb)
    $checkboxes += $cb
    $col++
    if ($col -ge 4) { $col = 0; $yPos += 24 }
}
$yPos += 30

$pnlAppBtns = New-Object Windows.Forms.Panel
$pnlAppBtns.Location = New-Object Drawing.Point(0, 460)
$pnlAppBtns.Size = New-Object Drawing.Size(740, 48)
$pnlAppBtns.BackColor = $cPanel
$tabApps.Controls.Add($pnlAppBtns)

$lblFoss = New-Object Windows.Forms.Label
$lblFoss.Text = "  Azul claro = FOSS (Software Libre y de código abierto)"
$lblFoss.ForeColor = $cAccent2
$lblFoss.Location = New-Object Drawing.Point(10, 14)
$lblFoss.Size = New-Object Drawing.Size(330, 20)
$pnlAppBtns.Controls.Add($lblFoss)

$btnInstallApps = New-Btn "  Instalar Seleccionadas" 520 7 210 34 "good"
$btnInstallApps.Add_Click({
    $sel = $checkboxes | Where-Object { $_.Checked }
    if ($sel.Count -eq 0) { Write-Out "No seleccionaste ninguna aplicación." ([Drawing.Color]::Yellow); return }
    Write-Out "Instalando $($sel.Count) aplicación(es)..." $cSubText
    Start-Progress
    foreach ($cb in $sel) {
        Write-Out "Instalando: $($cb.Text)..." $cSubText
        Start-Process powershell -ArgumentList "-NoProfile -Command `"$($cb.Tag)`"" -Wait -WindowStyle Hidden
        Write-Out "  $($cb.Text) instalado." ([Drawing.Color]::LightGreen)
        [Windows.Forms.Application]::DoEvents()
    }
    Stop-Progress
    Write-Out "Instalación finalizada." ([Drawing.Color]::LightGreen)
})
$pnlAppBtns.Controls.Add($btnInstallApps)

$btnClearSel = New-Btn "  Limpiar Selección" 330 7 180 34
$btnClearSel.Add_Click({ $checkboxes | ForEach-Object { $_.Checked = $false } })
$pnlAppBtns.Controls.Add($btnClearSel)

# ============================================================
#   TAB 3: TWEAKS
# ============================================================
$tweaks = @(
    @{name="Plan energía: Alto rendimiento"; cmd='powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'; tip="Activa el plan de energía de máximo rendimiento"},
    @{name="Deshabilitar efectos visuales";  cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f'; tip="Desactiva animaciones para mayor rendimiento"},
    @{name="Deshabilitar notificaciones";    cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f'; tip="Desactiva las notificaciones Toast"},
    @{name="Deshabilitar Telemetría";        cmd='reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f'; tip="Evita que Windows envíe datos de diagnóstico a Microsoft"},
    @{name="Deshabilitar Cortana";           cmd='reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f'; tip="Desactiva Cortana por política de sistema"},
    @{name="Modo Juego activado";            cmd='reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f'; tip="Activa el modo de juego de Windows para mejor rendimiento en juegos"},
    @{name="Mostrar extensiones de archivo"; cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f'; tip="Hace visibles las extensiones de archivo (.exe, .pdf, etc.)"},
    @{name="Mostrar archivos ocultos";       cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f'; tip="Muestra archivos y carpetas ocultos en el Explorador"},
    @{name="Deshabilitar inicio rápido";     cmd='powercfg /h off'; tip="Desactiva el inicio rápido (soluciona problemas con actualizaciones)"},
    @{name="Deshabilitar Xbox Game Bar";     cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f'; tip="Desactiva la barra de juegos Xbox para liberar recursos"},
    @{name="Desactivar búsqueda en taskbar"; cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f'; tip="Oculta el cuadro de búsqueda de la barra de tareas"},
    @{name="Activar modo oscuro";            cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f'; tip="Activa el tema oscuro para las aplicaciones"}
)

New-SectionLabel "  Tweaks de Rendimiento y Privacidad" 10 8 $tabTweaks
$tweakScroll = New-Object Windows.Forms.Panel
$tweakScroll.Location = New-Object Drawing.Point(5, 32)
$tweakScroll.Size = New-Object Drawing.Size(730, 380)
$tweakScroll.AutoScroll = $true
$tweakScroll.BackColor = $cBg
$tabTweaks.Controls.Add($tweakScroll)

$yT = 5; $colT = 0; $tweakChecks = @()
foreach ($tw in $tweaks) {
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $tw.name
    $cb.Location = New-Object Drawing.Point((5 + $colT * 360), $yT)
    $cb.Size = New-Object Drawing.Size(350, 24)
    $cb.ForeColor = $cText
    $cb.BackColor = $cBg
    $cb.Tag = $tw.cmd
    $tip.SetToolTip($cb, $tw.tip)
    $tweakScroll.Controls.Add($cb)
    $tweakChecks += $cb
    $colT++
    if ($colT -ge 2) { $colT = 0; $yT += 28 }
}

$btnApplyTweaks = New-Btn "  Aplicar Tweaks Seleccionados" 5 425 270 36 "good"
$btnApplyTweaks.Add_Click({
    $sel = $tweakChecks | Where-Object { $_.Checked }
    if ($sel.Count -eq 0) { Write-Out "No seleccionaste ningún tweak." ([Drawing.Color]::Yellow); return }
    if (Confirm-Action "¿Aplicar $($sel.Count) tweak(s) seleccionado(s)? Algunos pueden requerir reinicio.") {
        Start-Progress
        foreach ($cb in $sel) {
            Write-Out "Aplicando: $($cb.Text)..." $cSubText
            Invoke-Expression $cb.Tag 2>&1 | Out-Null
            Write-Out "  Listo." ([Drawing.Color]::LightGreen)
            [Windows.Forms.Application]::DoEvents()
        }
        Stop-Progress
        Write-Out "Todos los tweaks aplicados. Puede requerir reinicio." ([Drawing.Color]::LightGreen)
    }
})
$tabTweaks.Controls.Add($btnApplyTweaks)

$btnMarcarTodos = New-Btn "Marcar Todos" 285 425 160 36
$btnMarcarTodos.Add_Click({ $tweakChecks | ForEach-Object { $_.Checked = $true } })
$tabTweaks.Controls.Add($btnMarcarTodos)

$btnDesmarcarTodos = New-Btn "Desmarcar Todos" 455 425 160 36
$btnDesmarcarTodos.Add_Click({ $tweakChecks | ForEach-Object { $_.Checked = $false } })
$tabTweaks.Controls.Add($btnDesmarcarTodos)

# ============================================================
#   HELPERS COMUNES PARA UTILIDADES
# ============================================================
function Install-MsOffCrypto {
    $check = python -c "import msoffcrypto" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Out "Instalando msoffcrypto-tool..." $cSubText
        python -m pip install msoffcrypto-tool | Out-Null
    }
}

function New-UtilPanel($titulo, $subtitulo, $parent, $y, $h=120) {
    $pnl = New-Object Windows.Forms.Panel
    $pnl.Location = New-Object Drawing.Point(8, $y)
    $pnl.Size = New-Object Drawing.Size(720, $h)
    $pnl.BackColor = $cCard
    $pnl.BorderStyle = "FixedSingle"
    $parent.Controls.Add($pnl)
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = "  $titulo"
    $lbl.Location = New-Object Drawing.Point(0, 0)
    $lbl.Size = New-Object Drawing.Size(720, 28)
    $lbl.ForeColor = $cAccent2
    $lbl.BackColor = $cPanel
    $lbl.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $lbl.TextAlign = "MiddleLeft"
    $pnl.Controls.Add($lbl)
    $lblSub = New-Object Windows.Forms.Label
    $lblSub.Text = "  $subtitulo"
    $lblSub.Location = New-Object Drawing.Point(0, 28)
    $lblSub.Size = New-Object Drawing.Size(720, 18)
    $lblSub.ForeColor = $cSubText
    $lblSub.Font = New-Object Drawing.Font("Segoe UI", 7)
    $pnl.Controls.Add($lblSub)
    return $pnl
}

# ============================================================
#   TAB 4: UTILIDADES (scroll)
# ============================================================
$utilScroll = New-Object Windows.Forms.Panel
$utilScroll.Location = New-Object Drawing.Point(0, 0)
$utilScroll.Size = New-Object Drawing.Size(740, 510)
$utilScroll.AutoScroll = $true
$utilScroll.BackColor = $cBg
$tabUtils.Controls.Add($utilScroll)

# ── EXCEL ────────────────────────────────────────────────
$pnlExcel = New-UtilPanel "Quitar contraseña — Excel (.xlsx / .xls / .xlsm)" "Se creará una copia sin contraseña en la misma carpeta." $utilScroll 5

$lblExcelPath = New-Object Windows.Forms.Label
$lblExcelPath.Text = "Ningún archivo seleccionado"
$lblExcelPath.Location = New-Object Drawing.Point(10, 50)
$lblExcelPath.Size = New-Object Drawing.Size(700, 14)
$lblExcelPath.ForeColor = $cText
$lblExcelPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlExcel.Controls.Add($lblExcelPath)

$btnBrowseExcel = New-Btn "Buscar Excel" 10 68 140 30
$btnBrowseExcel.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Excel (*.xlsx;*.xls;*.xlsm)|*.xlsx;*.xls;*.xlsm"
    if ($dlg.ShowDialog() -eq "OK") { $lblExcelPath.Text = $dlg.FileName }
})
$pnlExcel.Controls.Add($btnBrowseExcel)

$btnRemoveExcel = New-Btn "Quitar Contraseña" 160 68 180 30 "good"
$btnRemoveExcel.Add_Click({
    $path = $lblExcelPath.Text
    if (-not (Test-Path $path)) { Write-Out "Selecciona un archivo Excel primero." ([Drawing.Color]::Yellow); return }
    if (-not (Get-Command python -EA SilentlyContinue)) { Write-Out "Python no está instalado. Instala Python 3 primero." ([Drawing.Color]::Salmon); return }
    Install-MsOffCrypto
    $out = $path -replace '(\.[^.]+)$','_sin_pass$1'
    $py = "import msoffcrypto`nwith open(r'$path','rb') as f:`n    o=msoffcrypto.OfficeFile(f)`n    o.load_key(password='')`n    with open(r'$out','wb') as fw: o.decrypt(fw)`nprint('OK')"
    $tmp = "$env:TEMP\unlock_excel.py"
    $py | Set-Content $tmp -Encoding UTF8
    Start-Progress
    $res = python $tmp 2>&1
    Stop-Progress
    if ($res -like "*OK*") { Write-Out "Excel desbloqueado: $out" ([Drawing.Color]::LightGreen) }
    else { Write-Out "Error: $res" ([Drawing.Color]::Salmon) }
})
$pnlExcel.Controls.Add($btnRemoveExcel)

# ── WORD ─────────────────────────────────────────────────
$pnlWord = New-UtilPanel "Quitar contraseña — Word (.docx / .doc / .docm)" "Se creará una copia sin contraseña en la misma carpeta." $utilScroll 135

$lblWordPath = New-Object Windows.Forms.Label
$lblWordPath.Text = "Ningún archivo seleccionado"
$lblWordPath.Location = New-Object Drawing.Point(10, 50)
$lblWordPath.Size = New-Object Drawing.Size(700, 14)
$lblWordPath.ForeColor = $cText
$lblWordPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlWord.Controls.Add($lblWordPath)

$btnBrowseWord = New-Btn "Buscar Word" 10 68 140 30
$btnBrowseWord.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Word (*.docx;*.doc;*.docm)|*.docx;*.doc;*.docm"
    if ($dlg.ShowDialog() -eq "OK") { $lblWordPath.Text = $dlg.FileName }
})
$pnlWord.Controls.Add($btnBrowseWord)

$btnRemoveWord = New-Btn "Quitar Contraseña" 160 68 180 30 "good"
$btnRemoveWord.Add_Click({
    $path = $lblWordPath.Text
    if (-not (Test-Path $path)) { Write-Out "Selecciona un archivo Word primero." ([Drawing.Color]::Yellow); return }
    if (-not (Get-Command python -EA SilentlyContinue)) { Write-Out "Python no está instalado." ([Drawing.Color]::Salmon); return }
    Install-MsOffCrypto
    $out = $path -replace '(\.[^.]+)$','_sin_pass$1'
    $py = "import msoffcrypto`nwith open(r'$path','rb') as f:`n    o=msoffcrypto.OfficeFile(f)`n    o.load_key(password='')`n    with open(r'$out','wb') as fw: o.decrypt(fw)`nprint('OK')"
    $tmp = "$env:TEMP\unlock_word.py"
    $py | Set-Content $tmp -Encoding UTF8
    Start-Progress
    $res = python $tmp 2>&1
    Stop-Progress
    if ($res -like "*OK*") { Write-Out "Word desbloqueado: $out" ([Drawing.Color]::LightGreen) }
    else { Write-Out "Error: $res" ([Drawing.Color]::Salmon) }
})
$pnlWord.Controls.Add($btnRemoveWord)

# ── ZIP ──────────────────────────────────────────────────
$pnlZip = New-UtilPanel "Quitar contraseña — ZIP" "Ingresa la contraseña, o usa fuerza bruta con un wordlist (.txt)." $utilScroll 265 175

$lblZipPath = New-Object Windows.Forms.Label
$lblZipPath.Text = "Ningún archivo seleccionado"
$lblZipPath.Location = New-Object Drawing.Point(10, 50)
$lblZipPath.Size = New-Object Drawing.Size(400, 14)
$lblZipPath.ForeColor = $cText
$lblZipPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlZip.Controls.Add($lblZipPath)

$lblWlPath = New-Object Windows.Forms.Label
$lblWlPath.Text = "Sin wordlist"
$lblWlPath.Location = New-Object Drawing.Point(420, 50)
$lblWlPath.Size = New-Object Drawing.Size(290, 14)
$lblWlPath.ForeColor = $cSubText
$lblWlPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlZip.Controls.Add($lblWlPath)

$lblPassLbl = New-Object Windows.Forms.Label
$lblPassLbl.Text = "Contraseña:"
$lblPassLbl.Location = New-Object Drawing.Point(10, 70)
$lblPassLbl.Size = New-Object Drawing.Size(80, 20)
$lblPassLbl.ForeColor = $cText
$lblPassLbl.Font = New-Object Drawing.Font("Segoe UI", 8)
$pnlZip.Controls.Add($lblPassLbl)

$txtZipPass = New-Object Windows.Forms.TextBox
$txtZipPass.Location = New-Object Drawing.Point(95, 68)
$txtZipPass.Size = New-Object Drawing.Size(180, 22)
$txtZipPass.UseSystemPasswordChar = $true
$txtZipPass.BackColor = [Drawing.Color]::FromArgb(10,18,40)
$txtZipPass.ForeColor = $cText
$pnlZip.Controls.Add($txtZipPass)

$btnBrowseZip = New-Btn "Buscar ZIP" 10 96 130 28
$btnBrowseZip.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "ZIP (*.zip)|*.zip"
    if ($dlg.ShowDialog() -eq "OK") { $lblZipPath.Text = $dlg.FileName }
})
$pnlZip.Controls.Add($btnBrowseZip)

$btnBrowseWl = New-Btn "Wordlist" 150 96 130 28
$btnBrowseWl.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Text (*.txt)|*.txt"
    if ($dlg.ShowDialog() -eq "OK") { $lblWlPath.Text = $dlg.FileName }
})
$pnlZip.Controls.Add($btnBrowseWl)

$btnUnzipPass = New-Btn "Extraer / Quitar Contraseña" 290 96 230 28 "good"
$btnUnzipPass.Add_Click({
    $zipPath = $lblZipPath.Text
    $pass    = $txtZipPass.Text.Trim()
    $wl      = $lblWlPath.Text
    if (-not (Test-Path $zipPath)) { Write-Out "Selecciona un archivo ZIP primero." ([Drawing.Color]::Yellow); return }
    $outDir  = [IO.Path]::Combine([IO.Path]::GetDirectoryName($zipPath), [IO.Path]::GetFileNameWithoutExtension($zipPath) + "_extraido")
    $pyScript = @"
import zipfile, os, sys
path  = r'ZIPPATH'
out   = r'OUTDIR'
pwd   = 'ZIPPASS'
wl    = r'WLPATH'
os.makedirs(out, exist_ok=True)
if pwd:
    try:
        with zipfile.ZipFile(path) as z: z.extractall(out, pwd=pwd.encode())
        print('OK:Extraido con contraseña en: ' + out); sys.exit()
    except Exception as e: print('ERROR:' + str(e)); sys.exit()
try:
    with zipfile.ZipFile(path) as z: z.extractall(out)
    print('OK:Extraido sin contraseña en: ' + out); sys.exit()
except RuntimeError: pass
if os.path.exists(wl):
    print('INFO:Fuerza bruta iniciada...')
    with open(wl,'r',errors='ignore') as f:
        for i,line in enumerate(f):
            p = line.strip()
            try:
                with zipfile.ZipFile(path) as z: z.extractall(out, pwd=p.encode())
                print('OK:Contraseña encontrada: ' + p + ' | Extraido en: ' + out); sys.exit()
            except: pass
            if i % 500 == 0: print('INFO:Probadas ' + str(i) + ' contraseñas...')
    print('ERROR:No se encontró la contraseña en el wordlist.')
else:
    print('ERROR:ZIP protegido. Ingresa contraseña o selecciona un wordlist.')
"@
    $pyScript = $pyScript.Replace('ZIPPATH',$zipPath).Replace('OUTDIR',$outDir).Replace('ZIPPASS',$pass).Replace('WLPATH',$wl)
    $tmp = "$env:TEMP\unlock_zip.py"
    $pyScript | Set-Content $tmp -Encoding UTF8
    Write-Out "Procesando ZIP..." $cSubText
    Start-Progress
    $res = python $tmp 2>&1
    Stop-Progress
    foreach ($line in $res) {
        if     ($line -like "OK:*")   { Write-Out $line.Replace("OK:","") ([Drawing.Color]::LightGreen) }
        elseif ($line -like "ERROR:*"){ Write-Out $line.Replace("ERROR:","") ([Drawing.Color]::Salmon) }
        else                          { Write-Out $line $cSubText }
    }
})
$pnlZip.Controls.Add($btnUnzipPass)

# ── HASH CHECKER ─────────────────────────────────────────
$pnlHash = New-UtilPanel "Verificar Hash de Archivo (MD5 / SHA1 / SHA256)" "Útil para verificar integridad de descargas." $utilScroll 450

$lblHashPath = New-Object Windows.Forms.Label
$lblHashPath.Text = "Ningún archivo seleccionado"
$lblHashPath.Location = New-Object Drawing.Point(10, 50)
$lblHashPath.Size = New-Object Drawing.Size(700, 14)
$lblHashPath.ForeColor = $cText
$lblHashPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlHash.Controls.Add($lblHashPath)

$btnBrowseHash = New-Btn "Seleccionar Archivo" 10 68 180 30
$btnBrowseHash.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Todos los archivos (*.*)|*.*"
    if ($dlg.ShowDialog() -eq "OK") { $lblHashPath.Text = $dlg.FileName }
})
$pnlHash.Controls.Add($btnBrowseHash)

$btnGetHash = New-Btn "Calcular Hashes" 200 68 170 30 "good"
$btnGetHash.Add_Click({
    $path = $lblHashPath.Text
    if (-not (Test-Path $path)) { Write-Out "Selecciona un archivo primero." ([Drawing.Color]::Yellow); return }
    Start-Progress
    $md5    = (Get-FileHash $path -Algorithm MD5).Hash
    $sha1   = (Get-FileHash $path -Algorithm SHA1).Hash
    $sha256 = (Get-FileHash $path -Algorithm SHA256).Hash
    Stop-Progress
    Write-Out "── Hash de: $(Split-Path $path -Leaf)" $cAccent2
    Write-Out "MD5    : $md5" $cText
    Write-Out "SHA1   : $sha1" $cText
    Write-Out "SHA256 : $sha256" $cText
})
$pnlHash.Controls.Add($btnGetHash)

# ============================================================
#   TAB 5: SERVICIOS
# ============================================================
New-SectionLabel "  Gestión de Servicios de Windows" 10 8 $tabServices

$bloatServices = @(
    @{name="DiagTrack";            desc="Telemetría de diagnóstico (Datos a Microsoft)"},
    @{name="dmwappushservice";     desc="WAP Push Message Routing (telemetría)"},
    @{name="SysMain";              desc="SuperFetch (precarga apps, alto uso de disco)"},
    @{name="WSearch";              desc="Indexación de búsqueda de Windows"},
    @{name="XblAuthManager";       desc="Xbox Live Auth Manager"},
    @{name="XblGameSave";          desc="Xbox Live Game Save"},
    @{name="XboxNetApiSvc";        desc="Xbox Network Service"},
    @{name="MapsBroker";           desc="Descarga de mapas offline"},
    @{name="RetailDemo";           desc="Modo demo de tienda"},
    @{name="TabletInputService";   desc="Servicio de teclado táctil y panel"},
    @{name="Fax";                  desc="Servicio de Fax (obsoleto)"},
    @{name="PrintNotify";          desc="Notificaciones de impresora"}
)

$svcScroll = New-Object Windows.Forms.Panel
$svcScroll.Location = New-Object Drawing.Point(5, 32)
$svcScroll.Size = New-Object Drawing.Size(730, 380)
$svcScroll.AutoScroll = $true
$svcScroll.BackColor = $cBg
$tabServices.Controls.Add($svcScroll)

$svcChecks = @()
$ySvc = 5

foreach ($svc in $bloatServices) {
    $pnlSvc = New-Object Windows.Forms.Panel
    $pnlSvc.Location = New-Object Drawing.Point(5, $ySvc)
    $pnlSvc.Size = New-Object Drawing.Size(715, 30)
    $pnlSvc.BackColor = $cCard
    $svcScroll.Controls.Add($pnlSvc)

    $cbSvc = New-Object Windows.Forms.CheckBox
    $cbSvc.Location = New-Object Drawing.Point(5, 5)
    $cbSvc.Size = New-Object Drawing.Size(20, 20)
    $cbSvc.BackColor = $cCard
    $cbSvc.Tag = $svc.name
    $pnlSvc.Controls.Add($cbSvc)
    $svcChecks += $cbSvc

    $lblSvcName = New-Object Windows.Forms.Label
    $lblSvcName.Text = $svc.name
    $lblSvcName.Location = New-Object Drawing.Point(30, 7)
    $lblSvcName.Size = New-Object Drawing.Size(180, 18)
    $lblSvcName.ForeColor = $cAccent2
    $lblSvcName.Font = New-Object Drawing.Font("Consolas", 8)
    $pnlSvc.Controls.Add($lblSvcName)

    $lblSvcDesc = New-Object Windows.Forms.Label
    $lblSvcDesc.Text = $svc.desc
    $lblSvcDesc.Location = New-Object Drawing.Point(218, 7)
    $lblSvcDesc.Size = New-Object Drawing.Size(340, 18)
    $lblSvcDesc.ForeColor = $cSubText
    $lblSvcDesc.Font = New-Object Drawing.Font("Segoe UI", 8)
    $pnlSvc.Controls.Add($lblSvcDesc)

    # Estado actual
    $svcObj = Get-Service -Name $svc.name -EA SilentlyContinue
    $estado = if ($svcObj) { $svcObj.Status.ToString() } else { "No existe" }
    $lblSvcStatus = New-Object Windows.Forms.Label
    $lblSvcStatus.Text = $estado
    $lblSvcStatus.Location = New-Object Drawing.Point(565, 7)
    $lblSvcStatus.Size = New-Object Drawing.Size(80, 18)
    $lblSvcStatus.Font = New-Object Drawing.Font("Segoe UI", 8, [Drawing.FontStyle]::Bold)
    $lblSvcStatus.ForeColor = switch ($estado) {
        "Running"  { [Drawing.Color]::LightGreen }
        "Stopped"  { [Drawing.Color]::Salmon }
        default    { [Drawing.Color]::Gray }
    }
    $pnlSvc.Controls.Add($lblSvcStatus)

    $ySvc += 33
}

$btnDisableServices = New-Btn "Deshabilitar Seleccionados" 5 422 240 36 "warn"
$btnDisableServices.Add_Click({
    $sel = $svcChecks | Where-Object { $_.Checked }
    if ($sel.Count -eq 0) { Write-Out "Selecciona al menos un servicio." ([Drawing.Color]::Yellow); return }
    if (Confirm-Action "¿Deshabilitar $($sel.Count) servicio(s) seleccionado(s)?") {
        Start-Progress
        foreach ($cb in $sel) {
            $sname = $cb.Tag
            try {
                Stop-Service -Name $sname -Force -EA SilentlyContinue
                Set-Service  -Name $sname -StartupType Disabled -EA Stop
                Write-Out "Servicio deshabilitado: $sname" ([Drawing.Color]::LightGreen)
            } catch {
                Write-Out "Error con $sname : $_" ([Drawing.Color]::Salmon)
            }
        }
        Stop-Progress
    }
})
$tabServices.Controls.Add($btnDisableServices)

$btnEnableServices = New-Btn "Habilitar Seleccionados" 255 422 210 36 "good"
$btnEnableServices.Add_Click({
    $sel = $svcChecks | Where-Object { $_.Checked }
    if ($sel.Count -eq 0) { Write-Out "Selecciona al menos un servicio." ([Drawing.Color]::Yellow); return }
    Start-Progress
    foreach ($cb in $sel) {
        $sname = $cb.Tag
        try {
            Set-Service -Name $sname -StartupType Automatic -EA Stop
            Start-Service -Name $sname -EA SilentlyContinue
            Write-Out "Servicio habilitado: $sname" ([Drawing.Color]::LightGreen)
        } catch {
            Write-Out "Error con $sname : $_" ([Drawing.Color]::Salmon)
        }
    }
    Stop-Progress
})
$tabServices.Controls.Add($btnEnableServices)

$btnRefreshSvc = New-Btn "Actualizar estados" 475 422 180 36
$btnRefreshSvc.Add_Click({
    Write-Out "Actualizando estados de servicios..." $cSubText
    # Refrescar labels de estado (reconstruir requeriría redibujado, por simplicidad se indica al usuario)
    Write-Out "Cierra y vuelve a abrir la pestaña Servicios para ver estados actualizados." ([Drawing.Color]::Yellow)
})
$tabServices.Controls.Add($btnRefreshSvc)

# ============================================================
#   TAB 6: SISTEMA
# ============================================================
$infoBox = New-Object Windows.Forms.RichTextBox
$infoBox.Location = New-Object Drawing.Point(5, 5)
$infoBox.Size = New-Object Drawing.Size(730, 370)
$infoBox.BackColor = $cOutput
$infoBox.ForeColor = $cAccent2
$infoBox.Font = New-Object Drawing.Font("Consolas", 9)
$infoBox.ReadOnly = $true
$infoBox.BorderStyle = "None"
$tabInfo.Controls.Add($infoBox)

# Panel de stats rápidos
$statPanel = New-Object Windows.Forms.Panel
$statPanel.Location = New-Object Drawing.Point(5, 380)
$statPanel.Size = New-Object Drawing.Size(730, 80)
$statPanel.BackColor = $cCard
$tabInfo.Controls.Add($statPanel)

$btnInfo = New-Btn "Cargar Info del Sistema" 5 385 220 36 "good"
$btnInfo.Add_Click({
    $infoBox.Clear()
    Start-Progress
    $os   = Get-CimInstance Win32_OperatingSystem
    $cpu  = Get-CimInstance Win32_Processor
    $gpu  = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Caption
    $mem  = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $disk = Get-PSDrive C
    $ip   = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' } | Select-Object -First 1).IPAddress
    $boot = $os.LastBootUpTime
    $up   = (Get-Date) - $boot

    $infoBox.AppendText("═══════════════════════════════════════`r`n")
    $infoBox.AppendText(" SISTEMA OPERATIVO`r`n")
    $infoBox.AppendText("═══════════════════════════════════════`r`n")
    $infoBox.AppendText(" SO              : $($os.Caption)`r`n")
    $infoBox.AppendText(" Versión         : $($os.Version) ($($os.BuildNumber))`r`n")
    $infoBox.AppendText(" Arquitectura    : $($os.OSArchitecture)`r`n")
    $infoBox.AppendText(" Nombre equipo   : $env:COMPUTERNAME`r`n")
    $infoBox.AppendText(" Usuario actual  : $env:USERNAME`r`n")
    $infoBox.AppendText(" Último arranque : $boot`r`n")
    $infoBox.AppendText(" Uptime          : $($up.Days)d $($up.Hours)h $($up.Minutes)m`r`n")
    $infoBox.AppendText("`r`n")
    $infoBox.AppendText("═══════════════════════════════════════`r`n")
    $infoBox.AppendText(" HARDWARE`r`n")
    $infoBox.AppendText("═══════════════════════════════════════`r`n")
    $infoBox.AppendText(" CPU             : $($cpu.Name)`r`n")
    $infoBox.AppendText(" Núcleos         : $($cpu.NumberOfCores) físicos / $($cpu.NumberOfLogicalProcessors) lógicos`r`n")
    $infoBox.AppendText(" GPU             : $gpu`r`n")
    $infoBox.AppendText(" RAM Total       : $mem GB`r`n")
    $infoBox.AppendText(" RAM Libre       : $free GB ($([math]::Round($free/$mem*100,1))% libre)`r`n")
    $infoBox.AppendText(" Disco C: Libre  : $([math]::Round($disk.Free/1GB,2)) GB de $([math]::Round(($disk.Used+$disk.Free)/1GB,2)) GB`r`n")
    $infoBox.AppendText("`r`n")
    $infoBox.AppendText("═══════════════════════════════════════`r`n")
    $infoBox.AppendText(" RED`r`n")
    $infoBox.AppendText("═══════════════════════════════════════`r`n")
    $infoBox.AppendText(" IP Local        : $ip`r`n")
    Stop-Progress
    Write-Out "Información del sistema cargada." ([Drawing.Color]::LightGreen)
})
$tabInfo.Controls.Add($btnInfo)

$btnUptime = New-Btn "Ver Uptime" 235 385 150 36
$btnUptime.Add_Click({
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up   = (Get-Date) - $boot
    Write-Out "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m desde $boot" $cText
})
$tabInfo.Controls.Add($btnUptime)

$btnTopProcs = New-Btn "Top 10 CPU/RAM" 395 385 180 36
$btnTopProcs.Add_Click({
    Write-Out "── Top 10 procesos por CPU ──" $cAccent2
    Get-Process | Sort-Object CPU -Desc | Select-Object -First 10 |
        ForEach-Object { Write-Out ("{0,-30} CPU: {1,8:N1}s   RAM: {2,6} MB" -f $_.Name, $_.CPU, [math]::Round($_.WorkingSet64/1MB,1)) $cText }
})
$tabInfo.Controls.Add($btnTopProcs)

$btnUpdates = New-Btn "Buscar Actualizaciones" 585 385 140 36
$btnUpdates.Add_Click({ Start-Process ms-settings:windowsupdate })
$tabInfo.Controls.Add($btnUpdates)

# ============================================================
#   FOOTER
# ============================================================
$footer = New-Object Windows.Forms.Label
$footer.Text = "SysCodi WinTool Pro v2.0  |  WinGet para instalaciones  |  Ejecutar siempre como Administrador"
$footer.Location = New-Object Drawing.Point(0, 638)
$footer.Size = New-Object Drawing.Size(1240, 22)
$footer.TextAlign = "MiddleCenter"
$footer.ForeColor = $cSubText
$footer.Font = New-Object Drawing.Font("Segoe UI", 7)
$footer.BackColor = $cPanel
$form.Controls.Add($footer)

# ============================================================
[Windows.Forms.Application]::Run($form)
