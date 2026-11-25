---
title: "Curling calls you can see"
subtitle: "An assistive device for deaf curlers"
date: 2024-03-01
period: "Winter 2024"
weight: 40
status: stub
context: "ECE 3760 group project"
role: "Most of the ESP32 firmware for both devices"
coverAlt: "A sweeper unit on a breadboard: an ESP32 and red, yellow and green LEDs"
summary: "In curling, the skip shouts sweeping calls down the ice. We built a wireless device that shows those calls as coloured lights, so deaf players can see them."
stack: ["ESP32", "ESP-NOW", "C++", "PlatformIO"]
video:
  src: "/media/deaf-curling/demo.mp4"
  poster: "/media/deaf-curling/demo.jpg"
  caption: "The demo: one skip unit and three sweeper units, all on breadboards."
---
In curling, the skip stands at the far end of the sheet and shouts to the sweepers when to sweep. For deaf and hard-of-hearing curlers, that channel doesn't work. Our team built a pair of ESP32 devices to replace the shout with light: the skip's handheld unit sends calls over ESP-NOW (the ESP32's low-latency peer-to-peer radio), and the sweeper's unit shows them on red, yellow and green LEDs, like a traffic light.

I wrote most of the firmware for both devices, rewriting the early prototype code around interrupts: debounced button and joystick input on the skip side, and automatic pairing and messaging between the two boards.

The full story is coming.

## In photos

{{< photo src="photos/2024-03-28-skip-sketch.jpg" date="2024-03-28" alt="Pen sketch of the skip controller from the top, side and front" >}}
My sketch of the skip controller: a one-handed grip with the joystick on top and the sweeper buttons on the front.
{{< /photo >}}

{{< photo src="photos/2024-04-16-skip-breadboard.jpg" date="2024-04-16" tall="true" alt="An ESP32 on a breadboard with a joystick and push buttons" >}}
The skip unit on a breadboard: an ESP32, the joystick and the sweeper-select buttons.
{{< /photo >}}

{{< photo src="photos/2024-04-16-sweeper-breadboard.jpg" date="2024-04-16" alt="An ESP32 on a breadboard with a red, yellow and green LED module" >}}
A sweeper unit. The lab version used an LED ring; the final one shows red, yellow and green, like a traffic light.
{{< /photo >}}

{{< photo src="photos/2024-04-19-print-fail.jpg" date="2024-04-19" tall="true" alt="Inside a 3D printer with an empty, failed print on the bed" >}}
The night before the demo, in the IEEE lab, trying to print my enclosure design. None of the prints came out, so the demo ran on breadboards.
{{< /photo >}}
