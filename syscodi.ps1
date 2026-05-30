Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
#   LOGO - Descarga desde GitHub
# ============================================================
$logoUrl = "https://raw.githubusercontent.com/syscodi7/Tools/main/sis.png"
$logoPath = "$env:TEMP\syscodi_logo.png"
try {
    Invoke-WebRequest -Uri $logoUrl -OutFile $logoPath -ErrorAction Stop
} catch {
    $logoPath = ""
}

# ============================================================
#   COLORES CORPORATIVOS
# ============================================================
$cBg       = [Drawing.Color]::FromArgb(15, 25, 50)       # fondo principal
$cPanel    = [Drawing.Color]::FromArgb(22, 38, 75)        # paneles
$cCard     = [Drawing.Color]::FromArgb(30, 50, 100)       # tarjetas/secciones
$cAccent   = [Drawing.Color]::FromArgb(0, 120, 215)       # azul Windows
$cAccent2  = [Drawing.Color]::FromArgb(0, 180, 255)       # azul claro FOSS
$cText     = [Drawing.Color]::White
$cSubText  = [Drawing.Color]::FromArgb(160, 200, 255)
$cBtn      = [Drawing.Color]::FromArgb(0, 100, 180)
$cBtnHov   = [Drawing.Color]::FromArgb(0, 140, 220)
$cOutput   = [Drawing.Color]::FromArgb(10, 18, 40)
$cBorder   = [Drawing.Color]::FromArgb(0, 120, 215)

# ============================================================
#   FORMULARIO PRINCIPAL
# ============================================================
$form = New-Object Windows.Forms.Form
$form.Text = "SysCodi WinTool Pro"
$form.Size = New-Object Drawing.Size(1200, 650)
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
$header.Size = New-Object Drawing.Size(1200, 60)
$header.Location = New-Object Drawing.Point(0, 0)
$header.BackColor = $cPanel
$form.Controls.Add($header)
$header.BringToFront()

# Logo PNG en el header
if (Test-Path $logoPath) {
    $logoPic = New-Object Windows.Forms.PictureBox
    $logoPic.Location = New-Object Drawing.Point(10, 5)
    $logoPic.Size = New-Object Drawing.Size(50, 50)
    $logoPic.SizeMode = "Zoom"
    $logoPic.BackColor = $cPanel
    $logoPic.Image = [Drawing.Image]::FromFile($logoPath)
    $header.Controls.Add($logoPic)
    try {
        $bmp = [Drawing.Bitmap][Drawing.Image]::FromFile($logoPath)
        $icon = [Drawing.Icon]::FromHandle($bmp.GetHicon())
        $form.Icon = $icon
    } catch {}
    $titleX = 70
} else {
    $titleX = 15
}

$lblTitle = New-Object Windows.Forms.Label
$lblTitle.Text = "SysCodi WinTool Pro"
$lblTitle.Font = New-Object Drawing.Font("Segoe UI", 14, [Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $cAccent2
$lblTitle.Location = New-Object Drawing.Point($titleX, 10)
$lblTitle.Size = New-Object Drawing.Size(400, 30)
$header.Controls.Add($lblTitle)

$lblSub = New-Object Windows.Forms.Label
$lblSub.Text = "Utilidad de sistema avanzada para Windows"
$lblSub.Font = New-Object Drawing.Font("Segoe UI", 8)
$lblSub.ForeColor = $cSubText
$lblSub.Location = New-Object Drawing.Point($titleX, 38)
$lblSub.Size = New-Object Drawing.Size(400, 16)
$header.Controls.Add($lblSub)

# ============================================================
#   TAB CONTROL (PESTAAS)
# ============================================================
$tabs = New-Object Windows.Forms.TabControl
$tabs.Location = New-Object Drawing.Point(5, 65)
$tabs.Size = New-Object Drawing.Size(720, 520)
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

$tabRepair  = New-Tab " Reparacin"
$tabApps    = New-Tab " Aplicaciones"
$tabTweaks  = New-Tab " Tweaks"
$tabUtils   = New-Tab "  Utilidades"
$tabInfo    = New-Tab "  Sistema"

# ============================================================
#   OUTPUT COMPARTIDO (parte baja)
# ============================================================
# Panel derecho - Consola
$rightPanel = New-Object Windows.Forms.Panel
$rightPanel.Location = New-Object Drawing.Point(728, 65)
$rightPanel.Size = New-Object Drawing.Size(455, 520)
$rightPanel.BackColor = [Drawing.Color]::FromArgb(10, 18, 40)
$form.Controls.Add($rightPanel)

$lblConsole = New-Object Windows.Forms.Label
$lblConsole.Text = "  Consola de salida"
$lblConsole.Location = New-Object Drawing.Point(0, 0)
$lblConsole.Size = New-Object Drawing.Size(455, 28)
$lblConsole.ForeColor = [Drawing.Color]::FromArgb(0, 180, 255)
$lblConsole.BackColor = [Drawing.Color]::FromArgb(22, 38, 75)
$lblConsole.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$lblConsole.TextAlign = "MiddleLeft"
$rightPanel.Controls.Add($lblConsole)

$btnClearOutput = New-Object Windows.Forms.Button
$btnClearOutput.Text = "Limpiar"
$btnClearOutput.Location = New-Object Drawing.Point(370, 3)
$btnClearOutput.Size = New-Object Drawing.Size(80, 22)
$btnClearOutput.BackColor = [Drawing.Color]::FromArgb(0, 100, 180)
$btnClearOutput.ForeColor = [Drawing.Color]::White
$btnClearOutput.FlatStyle = "Flat"
$btnClearOutput.Font = New-Object Drawing.Font("Segoe UI", 7)
$rightPanel.Controls.Add($btnClearOutput)

$outputBox = New-Object Windows.Forms.RichTextBox
$outputBox.Location = New-Object Drawing.Point(0, 30)
$outputBox.Size = New-Object Drawing.Size(455, 490)
$outputBox.BackColor = $cOutput
$outputBox.ForeColor = $cAccent2
$outputBox.Font = New-Object Drawing.Font("Consolas", 9)
$outputBox.ReadOnly = $true
$outputBox.BorderStyle = "None"
$outputBox.Text = "  Listo. Selecciona una opcin y ejecuta."
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
    try {
        $res = Invoke-Expression $cmd 2>&1
        Write-Out ($res -join "`r`n") $cText
    } catch {
        Write-Out "Error: $_" ([Drawing.Color]::Salmon)
    }
}

# ============================================================
#   HELPER: crear botn estilo corporativo
# ============================================================
function New-CorporateButton($texto, $x, $y, $w = 200, $h = 36) {
    $b = New-Object Windows.Forms.Button
    $b.Text = $texto
    $b.Location = New-Object Drawing.Point($x, $y)
    $b.Size = New-Object Drawing.Size($w, $h)
    $b.BackColor = $cBtn
    $b.ForeColor = $cText
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderColor = $cAccent
    $b.FlatAppearance.BorderSize = 1
    $b.Font = New-Object Drawing.Font("Segoe UI", 9)
    $b.Cursor = "Hand"
    return $b
}

function New-SectionLabel($texto, $x, $y, $parent) {
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $texto
    $lbl.Location = New-Object Drawing.Point($x, $y)
    $lbl.Size = New-Object Drawing.Size(860, 22)
    $lbl.ForeColor = $cAccent2
    $lbl.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
    $parent.Controls.Add($lbl)
}

# ============================================================
#   TAB 1: REPARACIN
# ============================================================
New-SectionLabel " Limpieza " 10 10 $tabRepair

$btnLimpiar = New-CorporateButton "  Limpiar Temporales" 10 35
$btnLimpiar.Add_Click({
    Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
    Write-Out " Temporales eliminados correctamente." ([Drawing.Color]::LightGreen)
})
$tabRepair.Controls.Add($btnLimpiar)

$btnPrefetch = New-CorporateButton "  Limpiar Prefetch" 220 35
$btnPrefetch.Add_Click({
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -EA SilentlyContinue
    Write-Out " Prefetch limpiado." ([Drawing.Color]::LightGreen)
})
$tabRepair.Controls.Add($btnPrefetch)

New-SectionLabel " Reparacin de Windows " 10 85 $tabRepair

$btnSFC = New-CorporateButton "  SFC /scannow" 10 110
$btnSFC.Add_Click({ Run-Cmd "sfc /scannow" })
$tabRepair.Controls.Add($btnSFC)

$btnDISM = New-CorporateButton "  DISM RestoreHealth" 220 110
$btnDISM.Add_Click({ Run-Cmd "DISM /Online /Cleanup-Image /RestoreHealth" })
$tabRepair.Controls.Add($btnDISM)

$btnChkDsk = New-CorporateButton "  CheckDisk (C:)" 430 110
$btnChkDsk.Add_Click({ Run-Cmd "chkdsk C: /f /r /x" })
$tabRepair.Controls.Add($btnChkDsk)

New-SectionLabel " Red " 10 160 $tabRepair

$btnDNS = New-CorporateButton "  DNS Flush" 10 185
$btnDNS.Add_Click({ Run-Cmd "ipconfig /flushdns" })
$tabRepair.Controls.Add($btnDNS)

$btnNetReset = New-CorporateButton "  Reset Red (netsh)" 220 185
$btnNetReset.Add_Click({
    Run-Cmd "netsh int ip reset"
    Run-Cmd "netsh winsock reset"
    Write-Out " Reinicia el PC para aplicar cambios de red." ([Drawing.Color]::Yellow)
})
$tabRepair.Controls.Add($btnNetReset)

$btnPuertos = New-CorporateButton "  Ver Puertos" 430 185
$btnPuertos.Add_Click({ Run-Cmd "netstat -ano" })
$tabRepair.Controls.Add($btnPuertos)

$btnKill80 = New-CorporateButton "  Matar Puerto 80" 640 185
$btnKill80.Add_Click({
    $pids = (netstat -ano | Select-String ":80\s") -replace '.*\s(\d+)$','$1' | Sort-Object -Unique
    foreach ($p in $pids) {
        if ($p -match '^\d+$') {
            Stop-Process -Id $p -Force -EA SilentlyContinue
            Write-Out " Proceso PID $p en puerto 80 terminado." ([Drawing.Color]::LightGreen)
        }
    }
})
$tabRepair.Controls.Add($btnKill80)

# ============================================================
#   TAB 2: APLICACIONES (con checkboxes)
# ============================================================
$scroll = New-Object Windows.Forms.Panel
$scroll.Location = New-Object Drawing.Point(0, 0)
$scroll.Size = New-Object Drawing.Size(875, 390)
$scroll.AutoScroll = $true
$scroll.BackColor = $cBg
$tabApps.Controls.Add($scroll)

$appList = @(
    @{cat="Navegadores";    name="Google Chrome";    cmd="winget install -e --id Google.Chrome"},
    @{cat="Navegadores";    name="Mozilla Firefox";  cmd="winget install -e --id Mozilla.Firefox"},
    @{cat="Navegadores";    name="Brave Browser";    cmd="winget install -e --id Brave.Brave"; foss=$true},
    @{cat="Navegadores";    name="LibreWolf";         cmd="winget install -e --id LibreWolf.LibreWolf"; foss=$true},
    @{cat="Comunicacin";   name="Discord";           cmd="winget install -e --id Discord.Discord"},
    @{cat="Comunicacin";   name="Telegram";          cmd="winget install -e --id Telegram.TelegramDesktop"; foss=$true},
    @{cat="Comunicacin";   name="Slack";             cmd="winget install -e --id SlackTechnologies.Slack"},
    @{cat="Comunicacin";   name="Signal";            cmd="winget install -e --id OpenWhisperSystems.Signal"; foss=$true},
    @{cat="Desarrollo";     name="VS Code";           cmd="winget install -e --id Microsoft.VisualStudioCode"},
    @{cat="Desarrollo";     name="Git";               cmd="winget install -e --id Git.Git"; foss=$true},
    @{cat="Desarrollo";     name="Python 3";          cmd="winget install -e --id Python.Python.3"; foss=$true},
    @{cat="Desarrollo";     name="NodeJS LTS";        cmd="winget install -e --id OpenJS.NodeJS.LTS"; foss=$true},
    @{cat="Utilidades";     name="7-Zip";             cmd="winget install -e --id 7zip.7zip"; foss=$true},
    @{cat="Utilidades";     name="VLC";               cmd="winget install -e --id VideoLAN.VLC"; foss=$true},
    @{cat="Utilidades";     name="WinRAR";            cmd="winget install -e --id RARLab.WinRAR"},
    @{cat="Utilidades";     name="Notepad++";         cmd="winget install -e --id Notepad++.Notepad++"; foss=$true}
)

$checkboxes = @()
$yPos = 5
$lastCat = ""
$col = 0
$yStart = 5

foreach ($app in $appList) {
    if ($app.cat -ne $lastCat) {
        $col = 0
        if ($lastCat -ne "") { $yPos += 10 }
        $lbl = New-Object Windows.Forms.Label
        $lbl.Text = " $($app.cat) "
        $lbl.Location = New-Object Drawing.Point(5, $yPos)
        $lbl.Size = New-Object Drawing.Size(860, 20)
        $lbl.ForeColor = $cAccent2
        $lbl.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
        $scroll.Controls.Add($lbl)
        $yPos += 22
        $lastCat = $app.cat
    }

    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $app.name
    $cb.Location = New-Object Drawing.Point((5 + $col * 210), $yPos)
    $cb.Size = New-Object Drawing.Size(200, 22)
    $cb.ForeColor = if ($app.foss) { $cAccent2 } else { $cText }
    $cb.BackColor = $cBg
    $cb.Tag = $app.cmd
    $scroll.Controls.Add($cb)
    $checkboxes += $cb

    $col++
    if ($col -ge 4) { $col = 0; $yPos += 25 }
    elseif ($col -eq 0) { $yPos += 0 }
}
$yPos += 30

$pnlAppBtns = New-Object Windows.Forms.Panel
$pnlAppBtns.Location = New-Object Drawing.Point(0, 395)
$pnlAppBtns.Size = New-Object Drawing.Size(875, 45)
$pnlAppBtns.BackColor = $cPanel
$tabApps.Controls.Add($pnlAppBtns)

$lblFoss = New-Object Windows.Forms.Label
$lblFoss.Text = " Azul claro = FOSS (Software Libre)"
$lblFoss.ForeColor = $cAccent2
$lblFoss.Location = New-Object Drawing.Point(10, 12)
$lblFoss.Size = New-Object Drawing.Size(300, 20)
$pnlAppBtns.Controls.Add($lblFoss)

$btnInstallApps = New-CorporateButton "  Instalar Seleccionadas" 530 5 200 34
$btnInstallApps.Add_Click({
    $sel = $checkboxes | Where-Object { $_.Checked }
    if ($sel.Count -eq 0) {
        Write-Out " No seleccionaste ninguna aplicacin." ([Drawing.Color]::Yellow)
        return
    }
    foreach ($cb in $sel) {
        Write-Out "Instalando: $($cb.Text)..." $cSubText
        Start-Process powershell -ArgumentList "-NoProfile -Command `"$($cb.Tag)`"" -Wait
        Write-Out " $($cb.Text) instalado." ([Drawing.Color]::LightGreen)
    }
})
$pnlAppBtns.Controls.Add($btnInstallApps)

$btnClear = New-CorporateButton "  Limpiar Seleccin" 320 5 200 34
$btnClear.Add_Click({ $checkboxes | ForEach-Object { $_.Checked = $false } })
$pnlAppBtns.Controls.Add($btnClear)

# ============================================================
#   TAB 3: TWEAKS
# ============================================================
New-SectionLabel " Rendimiento " 10 10 $tabTweaks

$tweaks = @(
    @{name=" Plan de energa: Alto rendimiento";  cmd='powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'},
    @{name=" Deshabilitar efectos visuales";       cmd='SystemPropertiesPerformance.exe'},
    @{name=" Deshabilitar notificaciones";         cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f'},
    @{name="  Deshabilitar Telemetra";             cmd='reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f'},
    @{name=" Deshabilitar Cortana";                cmd='reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f'},
    @{name="  Modo juego activado";                cmd='reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f'},
    @{name=" Mostrar extensiones de archivo";      cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f'},
    @{name="  Mostrar archivos ocultos";            cmd='reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f'}
)

$yT = 35
$colT = 0
$tweakChecks = @()
foreach ($tw in $tweaks) {
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $tw.name
    $cb.Location = New-Object Drawing.Point((10 + $colT * 430), $yT)
    $cb.Size = New-Object Drawing.Size(420, 24)
    $cb.ForeColor = $cText
    $cb.BackColor = $cBg
    $cb.Tag = $tw.cmd
    $tabTweaks.Controls.Add($cb)
    $tweakChecks += $cb
    $colT++
    if ($colT -ge 2) { $colT = 0; $yT += 28 }
}

$btnApplyTweaks = New-CorporateButton "  Aplicar Tweaks Seleccionados" 10 330 260 38
$btnApplyTweaks.Add_Click({
    $sel = $tweakChecks | Where-Object { $_.Checked }
    if ($sel.Count -eq 0) {
        Write-Out " No seleccionaste ningn tweak." ([Drawing.Color]::Yellow)
        return
    }
    foreach ($cb in $sel) {
        Write-Out "Aplicando: $($cb.Text)..." $cSubText
        Invoke-Expression $cb.Tag 2>&1 | Out-Null
        Write-Out " Listo." ([Drawing.Color]::LightGreen)
    }
    Write-Out " Todos los tweaks aplicados. Puede requerir reinicio." ([Drawing.Color]::LightGreen)
})
$tabTweaks.Controls.Add($btnApplyTweaks)


# ============================================================
#   TAB UTILIDADES - Quitar contrasenas
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
    $pnl.Size = New-Object Drawing.Size(690, $h)
    $pnl.BackColor = [Drawing.Color]::FromArgb(22, 38, 75)
    $parent.Controls.Add($pnl)
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $titulo
    $lbl.Location = New-Object Drawing.Point(10, 8)
    $lbl.Size = New-Object Drawing.Size(670, 22)
    $lbl.ForeColor = [Drawing.Color]::FromArgb(0, 180, 255)
    $lbl.Font = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
    $pnl.Controls.Add($lbl)
    $lblSub = New-Object Windows.Forms.Label
    $lblSub.Text = $subtitulo
    $lblSub.Location = New-Object Drawing.Point(10, 32)
    $lblSub.Size = New-Object Drawing.Size(670, 18)
    $lblSub.ForeColor = [Drawing.Color]::FromArgb(160, 200, 255)
    $lblSub.Font = New-Object Drawing.Font("Segoe UI", 8)
    $pnl.Controls.Add($lblSub)
    return $pnl
}

# ── EXCEL ─────────────────────────────────────────────────
$pnlExcel = New-UtilPanel "Quitar contrasena - Excel (.xlsx / .xls)" "Se creara una copia sin contrasena en la misma carpeta." $tabUtils 10

$lblExcelPath = New-Object Windows.Forms.Label
$lblExcelPath.Text = "Ningun archivo seleccionado"
$lblExcelPath.Location = New-Object Drawing.Point(10, 55)
$lblExcelPath.Size = New-Object Drawing.Size(670, 16)
$lblExcelPath.ForeColor = [Drawing.Color]::White
$lblExcelPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlExcel.Controls.Add($lblExcelPath)

$btnBrowseExcel = New-CorporateButton "Buscar Excel" 10 75 150 32
$btnBrowseExcel.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Excel files (*.xlsx;*.xls;*.xlsm)|*.xlsx;*.xls;*.xlsm"
    if ($dlg.ShowDialog() -eq "OK") { $lblExcelPath.Text = $dlg.FileName }
})
$pnlExcel.Controls.Add($btnBrowseExcel)

$btnRemoveExcel = New-CorporateButton "Quitar Contrasena" 170 75 180 32
$btnRemoveExcel.Add_Click({
    $path = $lblExcelPath.Text
    if (-not (Test-Path $path)) { Write-Out "Selecciona un archivo Excel primero." ([Drawing.Color]::Yellow); return }
    Install-MsOffCrypto
    $out = $path -replace '(\.[^.]+)$','_sin_pass$1'
    $py = "import msoffcrypto`nwith open(r'$path','rb') as f:`n    o=msoffcrypto.OfficeFile(f)`n    o.load_key(password='')`n    open(r'$out','wb').write(b'')`n    with open(r'$out','wb') as fw: o.decrypt(fw)`nprint('OK')"
    $tmp = "$env:TEMP\unlock_excel.py"
    $py | Set-Content $tmp -Encoding UTF8
    $res = python $tmp 2>&1
    if ($res -like "*OK*") { Write-Out "Excel desbloqueado: $out" ([Drawing.Color]::LightGreen) }
    else { Write-Out "Error: $res" ([Drawing.Color]::Salmon) }
})
$pnlExcel.Controls.Add($btnRemoveExcel)

# ── WORD ──────────────────────────────────────────────────
$pnlWord = New-UtilPanel "Quitar contrasena - Word (.docx / .doc)" "Se creara una copia sin contrasena en la misma carpeta." $tabUtils 140

$lblWordPath = New-Object Windows.Forms.Label
$lblWordPath.Text = "Ningun archivo seleccionado"
$lblWordPath.Location = New-Object Drawing.Point(10, 55)
$lblWordPath.Size = New-Object Drawing.Size(670, 16)
$lblWordPath.ForeColor = [Drawing.Color]::White
$lblWordPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlWord.Controls.Add($lblWordPath)

$btnBrowseWord = New-CorporateButton "Buscar Word" 10 75 150 32
$btnBrowseWord.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Word files (*.docx;*.doc;*.docm)|*.docx;*.doc;*.docm"
    if ($dlg.ShowDialog() -eq "OK") { $lblWordPath.Text = $dlg.FileName }
})
$pnlWord.Controls.Add($btnBrowseWord)

$btnRemoveWord = New-CorporateButton "Quitar Contrasena" 170 75 180 32
$btnRemoveWord.Add_Click({
    $path = $lblWordPath.Text
    if (-not (Test-Path $path)) { Write-Out "Selecciona un archivo Word primero." ([Drawing.Color]::Yellow); return }
    Install-MsOffCrypto
    $out = $path -replace '(\.[^.]+)$','_sin_pass$1'
    $py = "import msoffcrypto`nwith open(r'$path','rb') as f:`n    o=msoffcrypto.OfficeFile(f)`n    o.load_key(password='')`n    with open(r'$out','wb') as fw: o.decrypt(fw)`nprint('OK')"
    $tmp = "$env:TEMP\unlock_word.py"
    $py | Set-Content $tmp -Encoding UTF8
    $res = python $tmp 2>&1
    if ($res -like "*OK*") { Write-Out "Word desbloqueado: $out" ([Drawing.Color]::LightGreen) }
    else { Write-Out "Error: $res" ([Drawing.Color]::Salmon) }
})
$pnlWord.Controls.Add($btnRemoveWord)

# ── ZIP ───────────────────────────────────────────────────
$pnlZip = New-UtilPanel "Quitar contrasena - ZIP" "Ingresa la contrasena si la recuerdas, o usa fuerza bruta con un wordlist (.txt)." $tabUtils 270 160

$lblZipPath = New-Object Windows.Forms.Label
$lblZipPath.Text = "Ningun archivo seleccionado"
$lblZipPath.Location = New-Object Drawing.Point(10, 55)
$lblZipPath.Size = New-Object Drawing.Size(400, 16)
$lblZipPath.ForeColor = [Drawing.Color]::White
$lblZipPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlZip.Controls.Add($lblZipPath)

$lblWlPath = New-Object Windows.Forms.Label
$lblWlPath.Text = "Sin wordlist"
$lblWlPath.Location = New-Object Drawing.Point(420, 55)
$lblWlPath.Size = New-Object Drawing.Size(260, 16)
$lblWlPath.ForeColor = [Drawing.Color]::FromArgb(160, 200, 255)
$lblWlPath.Font = New-Object Drawing.Font("Consolas", 7)
$pnlZip.Controls.Add($lblWlPath)

$lblPassLbl = New-Object Windows.Forms.Label
$lblPassLbl.Text = "Contrasena:"
$lblPassLbl.Location = New-Object Drawing.Point(10, 76)
$lblPassLbl.Size = New-Object Drawing.Size(85, 20)
$lblPassLbl.ForeColor = [Drawing.Color]::White
$lblPassLbl.Font = New-Object Drawing.Font("Segoe UI", 8)
$pnlZip.Controls.Add($lblPassLbl)

$txtZipPass = New-Object Windows.Forms.TextBox
$txtZipPass.Location = New-Object Drawing.Point(98, 74)
$txtZipPass.Size = New-Object Drawing.Size(170, 22)
$txtZipPass.UseSystemPasswordChar = $true
$txtZipPass.BackColor = [Drawing.Color]::FromArgb(10,18,40)
$txtZipPass.ForeColor = [Drawing.Color]::White
$pnlZip.Controls.Add($txtZipPass)

$btnBrowseZip = New-CorporateButton "Buscar ZIP" 10 110 130 28
$btnBrowseZip.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "ZIP files (*.zip)|*.zip"
    if ($dlg.ShowDialog() -eq "OK") { $lblZipPath.Text = $dlg.FileName }
})
$pnlZip.Controls.Add($btnBrowseZip)

$btnBrowseWl = New-CorporateButton "Wordlist" 150 110 120 28
$btnBrowseWl.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Filter = "Text files (*.txt)|*.txt"
    if ($dlg.ShowDialog() -eq "OK") { $lblWlPath.Text = $dlg.FileName }
})
$pnlZip.Controls.Add($btnBrowseWl)

$btnUnzipPass = New-CorporateButton "Extraer / Quitar Contrasena" 280 110 220 28
$btnUnzipPass.Add_Click({
    $zipPath = $lblZipPath.Text
    $pass    = $txtZipPass.Text.Trim()
    $wl      = $lblWlPath.Text
    if (-not (Test-Path $zipPath)) { Write-Out "Selecciona un archivo ZIP primero." ([Drawing.Color]::Yellow); return }
    $outDir  = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($zipPath), [System.IO.Path]::GetFileNameWithoutExtension($zipPath) + "_extraido")
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
        print('OK:Extraido con contrasena en: ' + out); sys.exit()
    except Exception as e: print('ERROR:' + str(e)); sys.exit()
try:
    with zipfile.ZipFile(path) as z: z.extractall(out)
    print('OK:Extraido sin contrasena en: ' + out); sys.exit()
except RuntimeError: pass
if os.path.exists(wl):
    print('INFO:Fuerza bruta iniciada...')
    with open(wl,'r',errors='ignore') as f:
        for i,line in enumerate(f):
            p = line.strip()
            try:
                with zipfile.ZipFile(path) as z: z.extractall(out, pwd=p.encode())
                print('OK:Contrasena: ' + p + ' | Extraido en: ' + out); sys.exit()
            except: pass
            if i % 500 == 0: print('INFO:Probadas ' + str(i) + ' contrasenas...')
    print('ERROR:No se encontro la contrasena.')
else:
    print('ERROR:ZIP protegido. Ingresa contrasena o selecciona wordlist.')
"@
    $pyScript = $pyScript.Replace('ZIPPATH',$zipPath).Replace('OUTDIR',$outDir).Replace('ZIPPASS',$pass).Replace('WLPATH',$wl)
    $tmp = "$env:TEMP\unlock_zip.py"
    $pyScript | Set-Content $tmp -Encoding UTF8
    Write-Out "Procesando ZIP..." $cSubText
    $res = python $tmp 2>&1
    foreach ($line in $res) {
        if     ($line -like "OK:*")   { Write-Out $line.Replace("OK:","") ([Drawing.Color]::LightGreen) }
        elseif ($line -like "ERROR:*"){ Write-Out $line.Replace("ERROR:","") ([Drawing.Color]::Salmon) }
        else                          { Write-Out $line $cSubText }
    }
})
$pnlZip.Controls.Add($btnUnzipPass)


# ============================================================
#   TAB 5: INFO DEL SISTEMA
# ============================================================
$infoBox = New-Object Windows.Forms.RichTextBox
$infoBox.Location = New-Object Drawing.Point(5, 5)
$infoBox.Size = New-Object Drawing.Size(870, 340)
$infoBox.BackColor = $cOutput
$infoBox.ForeColor = $cAccent2
$infoBox.Font = New-Object Drawing.Font("Consolas", 9)
$infoBox.ReadOnly = $true
$infoBox.BorderStyle = "None"
$tabInfo.Controls.Add($infoBox)

$btnInfo = New-CorporateButton "  Cargar Info del Sistema" 5 355 220 36
$btnInfo.Add_Click({
    $infoBox.Clear()
    $os  = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $mem = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free= [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $disk= Get-PSDrive C
    $infoBox.AppendText("Sistema Operativo : $($os.Caption)`r`n")
    $infoBox.AppendText("Versin           : $($os.Version)`r`n")
    $infoBox.AppendText("Arquitectura      : $($os.OSArchitecture)`r`n")
    $infoBox.AppendText("Procesador        : $($cpu.Name)`r`n")
    $infoBox.AppendText("Ncleos           : $($cpu.NumberOfCores) ncleos / $($cpu.NumberOfLogicalProcessors) lgicos`r`n")
    $infoBox.AppendText("RAM Total         : $mem GB`r`n")
    $infoBox.AppendText("RAM Libre         : $free GB`r`n")
    $infoBox.AppendText("Disco C: Libre    : $([math]::Round($disk.Free/1GB,2)) GB de $([math]::Round(($disk.Used+$disk.Free)/1GB,2)) GB`r`n")
    $infoBox.AppendText("Nombre del equipo : $env:COMPUTERNAME`r`n")
    $infoBox.AppendText("Usuario actual    : $env:USERNAME`r`n")
    Write-Out " Informacin del sistema cargada." ([Drawing.Color]::LightGreen)
})
$tabInfo.Controls.Add($btnInfo)

$btnUptime = New-CorporateButton "  Ver Uptime" 235 355 160 36
$btnUptime.Add_Click({
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up   = (Get-Date) - $boot
    Write-Out "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m desde $boot" $cText
})
$tabInfo.Controls.Add($btnUptime)

$btnUpdates = New-CorporateButton "  Buscar Actualizaciones" 405 355 200 36
$btnUpdates.Add_Click({ Start-Process ms-settings:windowsupdate })
$tabInfo.Controls.Add($btnUpdates)

# ============================================================
#   FOOTER
# ============================================================
$footer = New-Object Windows.Forms.Label
$footer.Text = "SysCodi WinTool Pro  |  Usa WinGet como gestor de paquetes  |  Ejecutar siempre como Administrador"
$footer.Location = New-Object Drawing.Point(0, 620)
$footer.Size = New-Object Drawing.Size(1200, 20)
$footer.TextAlign = "MiddleCenter"
$footer.ForeColor = $cSubText
$footer.Font = New-Object Drawing.Font("Segoe UI", 7)
$form.Controls.Add($footer)

# ============================================================
$form.ShowDialog()
