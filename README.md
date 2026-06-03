# Windows Icon Changer

Small Windows utility to quickly change icons using a PowerShell script and a simple BAT launcher.

## Files

- `CambiaIcona.ps1` — main PowerShell script
- `Avvia_CambiaIcona.bat` — quick launcher for Windows

## Usage

1. Download or clone the repository.
2. Right click on `Avvia_CambiaIcona.bat`.
3. Run it.
4. Follow the script instructions.

If Windows blocks PowerShell execution, you may need to run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

```

## Notes

This tool is intended for personal use and small desktop customization tasks.

Depending on your Windows configuration, you may need to refresh the icon cache or restart Windows Explorer to see the changes.

## Disclaimer

This project is provided as-is, without any warranty.

Use it at your own risk. Before applying changes to important files, folders, or shortcuts, test the tool on non-critical items.

## License

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.
