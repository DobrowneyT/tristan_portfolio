---
title: "TeaMate"
subtitle: "A robot arm that makes your tea"
date: 2025-03-01
period: "Winter 2025"
weight: 20
status: stub
context: "Robotics project with Evan Evaniuk"
role: "Firmware: motion control, calibration and the brewing state machine"
summary: "A 3-DOF arm that picks up a tea bag, steeps it for exactly as long as you asked, agitates it, then throws it away."
stack: ["C++", "Arduino (MegaPi)", "PID control", "State machines"]
links:
  - { name: "GitHub", url: "https://github.com/DobrowneyT/teamate" }
video:
  src: ""        # e.g. /media/teamate/demo.mp4
  poster: ""
  youtube: ""    # add the YouTube link here
---
TeaMate is a three-joint robot arm on a Makeblock MegaPi (an Arduino Mega 2560). You set a steep time with a rotary encoder and put your cup down. It picks up a tea bag, lowers it in, dips it gently while counting down, plays a tune when your tea is ready, and drops the bag in the bin.

## How it works

- **Joint control:** each joint is a geared DC motor with an encoder, run by a PID position loop.
- **Self-calibration:** on boot, the base finds its range from two line markers, and the shoulder and elbow drive gently into their mechanical stops (stall detection) to find their limits.
- **A seven-state machine** runs the brew: setup → wait for cup → fetch bag → into cup → count down and agitate → bin → done. Timing uses `millis()`, so nothing blocks.
- **Five kinds of input:** joint encoders, an ultrasonic cup detector, a line sensor, a rotary encoder for the UI, and an OLED display with LEDs and a buzzer for feedback.

## The part that didn't make it

We wrote a Jacobian-based inverse-kinematics and path-planning library for the arm. The version that shipped moves through taught joint-space waypoints instead. The full write-up will cover why.
