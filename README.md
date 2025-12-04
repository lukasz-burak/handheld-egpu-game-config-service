# ROG Ally X eGPU Config Automator

This tool automatically switches your game graphics settings between **Handheld Mode** (Low/1080p) and **Docked Mode** (Ultra/4K) whenever you connect or disconnect your eGPU.

It is designed to be **Zero Resource**, meaning it sits silently in the background using **0% CPU** until it detects a hardware change event from Windows.

## 📂 Files Included

1. **`GPU_Config_Swapper.ps1`** - The "Brain." It watches for the eGPU and copies the files.

2. **`Setup_Auto_Switch.bat`** - The "Installer." It tells Windows to run the brain automatically when you log in.

## 🚀 Setup Instructions

### Step 1: Prepare Your Game Configs

Before you can automate, you need to create the "Master" copies of your settings.

1. **Create a folder** to store your configs (e.g., `C:\Configs`).

2. **Generate Handheld Settings:**

   * Unplug your eGPU.

   * Launch your game (e.g., Cyberpunk 2077).

   * Set Graphics to **Low** and Resolution to **1080p**.

   * Quit the game.

   * Go to where the game saves its config file (e.g., `%LOCALAPPDATA%\CD Projekt Red\Cyberpunk 2077`).

   * Copy the config file (e.g., `UserSettings.json`) to `C:\Configs\Cyberpunk\Handheld`.

3. **Generate Docked Settings:**

   * Plug in your eGPU.

   * Launch the game.

   * Set Graphics to **Ultra** and Resolution to **4K**.

   * Quit the game.

   * Copy the config file to `C:\Configs\Cyberpunk\Docked`.

### Step 2: Edit the Script

1. Open **`GPU_Config_Swapper.ps1`** with Notepad.

2. **Edit the `$eGPUKeyword`**:

   * Change `"NVIDIA"` to match your card if needed (e.g., `"AMD"` or `"RTX 4090"`).

3. **Edit the `$Games` list**:

   * Update the paths to match where you saved your files in Step 1.

   * Update the `Destination` to match where the game actually lives on your PC.

**Example:**

```powershell
@{
    Name = "Cyberpunk 2077"
    Destination = "C:\Users\YourName\AppData\Local\CD Projekt Red\Cyberpunk 2077"
    HandheldSource = "C:\Configs\Cyberpunk\Handheld"
    DockedSource = "C:\Configs\Cyberpunk\Docked"
}
