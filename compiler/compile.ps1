# compile.ps1
# Assembles all .ttslua source files into a single Tabletop Simulator mod JSON.
# Run from the repository root: .\compiler\compile.ps1
#
# Output: TTSJSON/40k_ai_controller.json
# Import that file into TTS via: Objects > Saved Objects > Import

param(
    [string]$OutputDir  = ".\TTSJSON",
    [string]$OutputFile = "40k_ai_controller.json",
    [string]$SrcDir     = ".\src"
)

# ─────────────────────────────────────────────────────────────────────────────
# Load order: dependencies must come before the files that use them.
# ─────────────────────────────────────────────────────────────────────────────
$LoadOrder = @(
    "config.ttslua",
    "systems\narrator.ttslua",
    "core\ftc_interface.ttslua",
    "core\board_state.ttslua",
    "army\datasheet_db.ttslua",
    "army\unit_tracker.ttslua",
    "army\army_manager.ttslua",
    "systems\dice_handler.ttslua",
    "systems\reserve_manager.ttslua",
    "systems\objective_tracker.ttslua",
    "systems\stratagem_manager.ttslua",
    "ai\threat_assessment.ttslua",
    "ai\decision_engine.ttslua",
    "phases\command_phase.ttslua",
    "phases\movement_phase.ttslua",
    "phases\shooting_phase.ttslua",
    "phases\charge_phase.ttslua",
    "phases\fight_phase.ttslua",
    "core\game_state.ttslua",
    "core\ai_main.ttslua"
)

# ─────────────────────────────────────────────────────────────────────────────
# Concatenate all Lua files into one script string
# ─────────────────────────────────────────────────────────────────────────────
$combinedLua = ""
foreach ($rel in $LoadOrder) {
    $path = Join-Path $SrcDir $rel
    if (-not (Test-Path $path)) {
        Write-Error "Missing source file: $path"
        exit 1
    }
    $combinedLua += "-- ### $rel ###`n"
    $combinedLua += (Get-Content $path -Raw -Encoding UTF8)
    $combinedLua += "`n`n"
}

Write-Host "Combined Lua script: $($combinedLua.Length) characters across $($LoadOrder.Count) files."

# ─────────────────────────────────────────────────────────────────────────────
# Build the TTS SavedObject JSON structure.
# This creates a single Tile object that hosts the AI controller script.
# The GUID is fixed so the mod can be re-imported without breaking saves.
# ─────────────────────────────────────────────────────────────────────────────
$ttsMod = [ordered]@{
    SaveName     = ""
    GameMode     = ""
    Gravity      = 0.5
    PlayArea     = 0.5
    Date         = ""
    Table        = ""
    Sky          = ""
    Note         = ""
    TabStates    = @{}
    LuaScript    = ""
    LuaScriptState = ""
    XmlUI        = ""
    ObjectStates = @(
        [ordered]@{
            GUID          = "40KAI01"
            Name          = "Tile"
            Transform     = [ordered]@{
                posX   = 0.0
                posY   = 2.0
                posZ   = 0.0
                rotX   = 0.0
                rotY   = 0.0
                rotZ   = 0.0
                scaleX = 2.0
                scaleY = 1.0
                scaleZ = 2.0
            }
            Nickname      = "40K FTC AI Controller"
            Description   = "AI controller for Warhammer 40K 10th edition FTC mod. Place alongside the FTC map, assign a side, set difficulty, then click START AI."
            GMNotes       = "FTC_AI_CONTROLLER"
            AltLookAngle  = [ordered]@{ x=0; y=0; z=0 }
            ColorDiffuse  = [ordered]@{ r=0.1; g=0.3; b=0.9 }
            LayoutGroupSortIndex = 0
            Value         = 0
            Locked        = $false
            Grid          = $true
            Snap          = $true
            IgnoreFoW     = $false
            MeasureMovement = $false
            DragSelectable  = $true
            Autoraise       = $true
            Sticky          = $true
            Tooltip         = $true
            GridProjection  = $false
            HideWhenFaceDown = $false
            Hands           = $false
            LuaScript       = $combinedLua
            LuaScriptState  = ""
            XmlUI           = ""
        }
    )
}

# ─────────────────────────────────────────────────────────────────────────────
# Write JSON output
# ─────────────────────────────────────────────────────────────────────────────
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$outPath = Join-Path $OutputDir $OutputFile
$ttsMod | ConvertTo-Json -Depth 20 | Set-Content -Path $outPath -Encoding UTF8

Write-Host "Output written to: $outPath"
Write-Host "Import into TTS: Objects > Saved Objects > Import, then select this file."
