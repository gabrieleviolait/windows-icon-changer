Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configurazione della Finestra Principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Cambia Icona File"
$form.Size = New-Object System.Drawing.Size(450, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.AllowDrop = $true

# Variabili di stato
$script:sourceFile = ""
$script:iconFile = ""

# Label Istruzioni / Drag & Drop Area
$lblDrop = New-Object System.Windows.Forms.Label
$lblDrop.Text = "Trascina qui il file (o clicca per selezionarlo)"
$lblDrop.Location = New-Object System.Drawing.Point(30, 20)
$lblDrop.Size = New-Object System.Drawing.Size(370, 60)
$lblDrop.BorderStyle = "FixedSingle"
$lblDrop.TextAlign = "MiddleCenter"
$lblDrop.BackColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($lblDrop)

# Label Stato File Selezionato
$lblSourceStatus = New-Object System.Windows.Forms.Label
$lblSourceStatus.Text = "Nessun file selezionato"
$lblSourceStatus.Location = New-Object System.Drawing.Point(30, 90)
$lblSourceStatus.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($lblSourceStatus)

# Label Stato Icona Selezionata
$lblIconStatus = New-Object System.Windows.Forms.Label
$lblIconStatus.Text = "Nessuna icona (.ico) selezionata"
$lblIconStatus.Location = New-Object System.Drawing.Point(30, 120)
$lblIconStatus.Size = New-Object System.Drawing.Size(370, 20)
$form.Controls.Add($lblIconStatus)

# Pulsante Applica
$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "Applica e Salva"
$btnApply.Location = New-Object System.Drawing.Point(150, 180)
$btnApply.Size = New-Object System.Drawing.Size(130, 40)
$btnApply.Enabled = $false
$form.Controls.Add($btnApply)

# --- LOGICA APPLICAZIONE ---

# Funzione per aprire l'Explorer e cercare il file .ico
function Seleziona-Icona {
    $objIconDialog = New-Object System.Windows.Forms.OpenFileDialog
    $objIconDialog.Filter = "File Icona (*.ico)|*.ico"
    $objIconDialog.Title = "Seleziona l'icona da applicare"
    
    if ($objIconDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:iconFile = $objIconDialog.FileName
        $lblIconStatus.Text = "Icona: " + [System.IO.Path]::GetFileName($script:iconFile)
        $btnApply.Enabled = $true
    }
}

# Gestione Click sulla drop area (Alternativa al Drag&Drop)
$lblDrop.add_Click({
    $objFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $objFileDialog.Filter = "Tutti i file (*.*)|*.*"
    if ($objFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:sourceFile = $objFileDialog.FileName
        $lblSourceStatus.Text = "File: " + [System.IO.Path]::GetFileName($script:sourceFile)
        Seleziona-Icona
    }
})

# Gestione Drag & Drop (Quando l'utente trascina il file sopra)
$form.add_DragEnter({
    param($sender, $e)
    if ($e.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
        $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
    }
})

# Gestione Rilascio del file (Drop)
$form.add_DragDrop({
    param($sender, $e)
    $files = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    if ($files.Count -gt 0) {
        $script:sourceFile = $files[0]
        $lblSourceStatus.Text = "File: " + [System.IO.Path]::GetFileName($script:sourceFile)
        
        # Ritardo minimo per fluidità visiva prima di aprire il file dialog dell'icona
        Start-Sleep -Milliseconds 200
        Seleziona-Icona
    }
})

# Logica del Pulsante Applica (Creazione del Collegamento / Shortcut con icona personalizzata)
$btnApply.add_Click({
    if ($script:sourceFile -and $script:iconFile) {
        
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "Collegamento Personalizzato (*.lnk)|*.lnk"
        $saveDialog.FileName = [System.IO.Path]::GetFileNameWithoutExtension($script:sourceFile)
        $saveDialog.Title = "Scegli dove salvare il file con la nuova icona"
        
        if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $WshShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut($saveDialog.FileName)
                $Shortcut.TargetPath = $script:sourceFile
                $Shortcut.IconLocation = $script:iconFile
                $Shortcut.Save()
                
                [System.Windows.Forms.MessageBox]::Show("File salvato con successo con la nuova icona!", "Operazione Completata", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                $form.Close()
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Errore durante il salvataggio: $_", "Errore", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    }
})

# Mostra l'applicazione
[System.Windows.Forms.Application]::Run($form)