#!/usr/bin/env python3
"""
compile.py — Python equivalent of compile.ps1 for Linux/Mac.
Assembles all .ttslua source files into a single TTS SavedObject JSON.

Usage:
    python3 compiler/compile.py
    python3 compiler/compile.py --src src --out TTSJSON/40k_ai_controller.json
"""

import json
import os
import argparse

LOAD_ORDER = [
    "config.ttslua",
    "systems/narrator.ttslua",
    "core/ftc_interface.ttslua",
    "core/board_state.ttslua",
    "army/datasheet_db.ttslua",
    "army/unit_tracker.ttslua",
    "army/army_manager.ttslua",
    "systems/dice_handler.ttslua",
    "systems/reserve_manager.ttslua",
    "systems/objective_tracker.ttslua",
    "systems/stratagem_manager.ttslua",
    "ai/threat_assessment.ttslua",
    "ai/decision_engine.ttslua",
    "phases/command_phase.ttslua",
    "phases/movement_phase.ttslua",
    "phases/shooting_phase.ttslua",
    "phases/charge_phase.ttslua",
    "phases/fight_phase.ttslua",
    "core/game_state.ttslua",
    "core/ai_main.ttslua",
]


def build(src_dir: str, out_path: str) -> None:
    combined = ""
    for rel in LOAD_ORDER:
        path = os.path.join(src_dir, rel)
        if not os.path.exists(path):
            raise FileNotFoundError(f"Missing source file: {path}")
        with open(path, encoding="utf-8") as f:
            combined += f"-- ### {rel} ###\n{f.read()}\n\n"

    tts = {
        "SaveName": "", "GameMode": "", "Gravity": 0.5, "PlayArea": 0.5,
        "Date": "", "Table": "", "Sky": "", "Note": "",
        "TabStates": {}, "LuaScript": "", "LuaScriptState": "", "XmlUI": "",
        "ObjectStates": [{
            "GUID": "40KAI01",
            "Name": "Tile",
            "Transform": {
                "posX": 0.0, "posY": 2.0, "posZ": 0.0,
                "rotX": 0.0, "rotY": 0.0, "rotZ": 0.0,
                "scaleX": 2.0, "scaleY": 1.0, "scaleZ": 2.0,
            },
            "Nickname": "40K FTC AI Controller",
            "Description": (
                "AI controller for Warhammer 40K 10th edition FTC mod. "
                "Place alongside the FTC map, assign a side, set difficulty, then click START AI."
            ),
            "GMNotes": "FTC_AI_CONTROLLER",
            "ColorDiffuse": {"r": 0.1, "g": 0.3, "b": 0.9},
            "Locked": False, "Grid": True, "Snap": True,
            "IgnoreFoW": False, "MeasureMovement": False,
            "LuaScript": combined,
            "LuaScriptState": "",
            "XmlUI": "",
        }],
    }

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(tts, f, indent=2, ensure_ascii=False)

    print(f"Combined {len(combined):,} chars from {len(LOAD_ORDER)} files")
    print(f"Output: {out_path}")
    print("Import into TTS: Objects > Saved Objects > Import")


if __name__ == "__main__":
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    parser = argparse.ArgumentParser(description="Compile 40K FTC AI mod Lua sources into TTS JSON")
    parser.add_argument("--src", default=os.path.join(repo_root, "src"),
                        help="Path to src directory")
    parser.add_argument("--out", default=os.path.join(repo_root, "TTSJSON", "40k_ai_controller.json"),
                        help="Output JSON file path")
    args = parser.parse_args()
    build(args.src, args.out)
