"""Builds realistic sample habits (schema 2) for the store screenshots.

Writes a SharedPreferences XML for the DEBUG app (com.trackflow.app.track_flow.dev)
on an emulator; never use it on a phone with real data. Usage:
    python tool/store/make_demo_seed.py YYYY-MM-DD out.xml
then: adb exec-in "run-as com.trackflow.app.track_flow.dev sh -c 'cat > shared_prefs/FlutterSharedPreferences.xml'" < out.xml
"""
import json
import random
import sys
from datetime import date, timedelta
from xml.sax.saxutils import escape

today = date.fromisoformat(sys.argv[1])
rng = random.Random(7)


def logs(days, scheduled, target, rate, today_value):
    out = {}
    for i in range(1, days + 1):
        d = today - timedelta(days=i)
        if d.isoweekday() not in scheduled:
            continue
        if rng.random() < rate:
            out[d.isoformat()] = target if target == 1 else max(1, target - rng.choice([0, 0, 0, 1, 2]))
    if today_value:
        out[today.isoformat()] = today_value
    return out


def habit(hid, title, cat, icon, color, kind, tod, target, unit, days, rate, start_days, today_value):
    return {
        "id": hid, "title": title, "category": cat, "iconCode": icon, "colorValue": color,
        "type": kind, "timeOfDay": tod, "targetPerDay": target, "unit": unit,
        "scheduledDays": days, "logs": logs(start_days, days, target, rate, today_value),
        "createdAt": (today - timedelta(days=start_days)).isoformat() + "T08:00:00.000",
        "isArchived": False,
    }


every = [1, 2, 3, 4, 5, 6, 7]
habits = [
    habit("h_water", "Hydration", "Fitness & Health", "water", 0xFF34A4D7, "measurable", "morning", 8, "glasses", every, 0.86, 140, 5),
    habit("h_run", "Morning Run", "Fitness & Health", "fitness", 0xFF1BB383, "boolean", "morning", 1, "times", [1, 3, 5, 6], 0.82, 120, 1),
    habit("h_deep", "Deep Work", "Deep Work", "timer", 0xFF686CE2, "measurable", "afternoon", 90, "mins", [1, 2, 3, 4, 5], 0.8, 110, 0),
    habit("h_read", "Read 20 Pages", "Learning", "book", 0xFF9E66CC, "measurable", "evening", 20, "pages", every, 0.72, 100, 0),
    habit("h_meditate", "Meditation", "Mindset", "mind", 0xFF33B3A6, "boolean", "anytime", 1, "times", every, 0.9, 90, 1),
    habit("h_screens", "No Screens After 10:30", "Daily Routine", "sleep", 0xFFCC4B61, "boolean", "evening", 1, "times", every, 0.65, 60, 0),
]
payload = json.dumps({"schemaVersion": 2, "habits": habits}, separators=(",", ":"))
xml = (
    "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n<map>\n"
    f'    <string name="flutter.track_flow_habits_v2">{escape(payload, {chr(34): "&quot;"})}</string>\n'
    "</map>\n"
)
with open(sys.argv[2], "w", encoding="utf-8", newline="\n") as f:
    f.write(xml)
print(len(payload), "chars,", sum(len(h["logs"]) for h in habits), "log entries")
