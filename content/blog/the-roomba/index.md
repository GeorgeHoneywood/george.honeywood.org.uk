---
title: "The Roomba"
date: 2023-01-17T14:11:01Z
draft: false
description: "Using a Roomba from 2009"
keywords: ["roomba"]
tags: ["projects"]
math: false
toc: false
comments: true
---

For Christmas one of my housemates got us a second-hand Roomba. I tried to not take this too personally. It came from Germany for the princely sum of £60, which got us the Roomba 555 from 2009.

{{< video path="docking-960x720.mp4" muted="true" >}}

Somewhat unsurprisingly, a 14-year-old Roomba is not the cleverest thing. I think this has made me like it more. I've zoomorphised it to some degree --- it has become our house pet, and is quite like owning an annoying cat. It seems to have two modes of operation; wall following and stochastic (random) bouncing about. This randomness is not particularly efficient.

Unlike modern robot vacuums, it cannot build a map of its environment, and thus tends to cover some areas multiple times and others not at all. However, it being autonomous means you can just leave it to run, and eventually it will get the job done acceptably or run out of battery. It is quite fun to watch it slowly clean up the grub on your floor.

In some ways I prefer it being a *vintage* device as it doesn't connect to Wi-Fi, or require a suspicious mobile app. You just press a button, or schedule a clean, and away it goes. When it runs low on battery it tries to dock automatically, but as the movement is random, it doesn't always make it home before the battery goes flat.

When it arrived, it was hilariously bad at vacuuming. It could suck up dust, but anything larger was completely ignored. After a while we figured out that the "beater bar" under it wasn't spinning at all. Luckily, unlike almost any other consumer electronic device I've owned, repairing the Roomba was pretty easy. It is made up of a number of modules that can be individually replaced as needed. Even these modules can be trivially opened with a normal Phillips head screwdriver, and repaired yourself if you have the parts.

In Roomba land, the beater bar is part of the "Cleaning Head Module". Nothing seemed to be visibly wrong with it, so I had a look inside the gearbox. Other than managing to strip one of the screws through impatience, it was pretty simple to get in. Once I had it open, the problem became rather obvious.

{{< image path="gearbox" alt="A very dirty gearbox" method="Resize" options="1000x" >}}

The gearbox was completely full of dust and hair. I'm not sure if this was a result of engineering oversight, or if it is just very difficult to seal a gearbox against 14 years of grime. This reminded me of a great [video by rctestflight](https://youtu.be/YhwthSaLgh4?t=1714), where he runs a selection of RC cars in circles for literal weeks to see how far they'll go. Some of them eventually failed after the universal joints driving the wheels wore down, and in others the gearboxes wore out, as mud got in and ate away at the gears.

The Roomba gearbox was broken in a slightly different fashion, as the gear connected to the motor had ended up wearing down so much it was slipping against the metal shaft. Presumably, if the gearbox had been cleaned at some point then it wouldn't have built up such resistance and might still be working. Unfortunately I couldn't replace the gears, as part of the gearbox housing had worn down to the point where there was so much play the gears didn't mesh any more.

Somewhat surprisingly, [iRobot still sells spares](https://www.irobot.co.uk/en_GB/enhanced-cleaning-head-for-roomba-500/600/700/21917.html) for the Cleaning Head Module that fits this model. Presumably this is due to it being a standardized part used over a number of generations. I bought one to replace my broken one, and other than the £6.50 (!) shipping charge their website worked well.

Annoyingly, immediately after this new part arrived, the Roomba stopped charging --- complaining of `Err5`. I wasn't sure if this was a problem with the charger or the battery, but I ended up replacing the battery with a 3rd party Ni-MH one from Amazon, which seemed to revive it. For these new parts I spent a total of £63.47 (£36.49 for the Cleaning Head and £26.98 for the battery), making the total spend about £120. This is significantly cheaper than the lowest end model iRobot currently sell, the [Roomba® 698, on offer for £199.00](https://web.archive.org/web/20230117175042/https://www.irobot.co.uk/en_GB/irobot-roomba-692/R692040.html). 

Once I had installed the new parts, its cleaning performance improved dramatically. It can now pick up larger bits of dirt, and even gets fluffs and hairs up from the low pile carpets we have. One feature I am particularly fond of is "Dirt Detect", which uses some kind of contact microphone in the Cleaning Head to detect dirty spots. When it finds one, it circles back and gives the area a second pass. It also has a "Spot" mode, where it cleans in concentric circles if you have a specific area that needs special attention.

{{< image path="docked" alt="The Roomba docked and charging up" method="Resize" options="1000x" >}}

I still need to replace the side brush on it. This is what would normally enable it to reach dirt that is close to the walls. For now, I have been manually brushing dirt into the middle of the floor, which you could argue defeats the point of a robot vacuum.
