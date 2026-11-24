---
title: "Curling calls you can see"
subtitle: "An assistive device for deaf curlers"
date: 2024-03-01
period: "Winter 2024"
weight: 40
status: stub
context: "ECE 3760 group project"
role: "ESP32 firmware for the skip and sweeper devices"
summary: "In curling, the skip shouts sweeping calls down the ice. We built a wireless device that shows those calls on a light ring, so deaf players can see them."
stack: ["ESP32", "ESP-NOW", "C++", "PlatformIO", "NeoPixel LEDs"]
---
In curling, the skip stands at the far end of the sheet and shouts to the sweepers when to sweep. For deaf and hard-of-hearing curlers, that channel doesn't work. Our team built a pair of ESP32 devices to replace the shout with light: the skip's handheld unit sends calls over ESP-NOW (the ESP32's low-latency peer-to-peer radio), and the sweeper's unit shows them on a ring of LEDs.

I wrote the firmware for both devices: interrupt-driven, debounced button input on the skip side, and pairing and messaging between the two boards.

Photos and the full story are coming.
