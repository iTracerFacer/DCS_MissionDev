-- Define Menu functions
local msgTime = 15
local mission_msg_time = 60 

function high_value_target_dead()
  MESSAGE:New("Congratulations! NATO Forces have destroyed a high value target (HVT) in the Gaza strip. Israeli forces have been reinforced!!", msgTime, "PROGRESS", false):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  Spawn_Blue_Israel_Reinforcements:Spawn()
end

function deep_strike_success()
  MESSAGE:New("Congratulations! NATO Forces have completed a deep stike mission. Israeli forces have been reinforced!!", msgTime, "PROGRESS", false):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  Spawn_Blue_Israel_Reinforcements:Spawn()
  Spawn_Blue_Israel_Reinforcements:Spawn()
end

function med_supply_delivery_success()
  MESSAGE:New("Congratulations! NATO Forces have delivered humanitarian aid to a refugee location. Israeli forces have been reinforced!!", msgTime, "PROGRESS", false):ToBlue()
  USERSOUND:New("morsecode.ogg"):ToCoalition(coalition.side.BLUE)
  Spawn_Blue_Israel_Reinforcements:Spawn()
  Spawn_Blue_Israel_Reinforcements:Spawn()
end

function DeepStrikesBaluza1()
  MESSAGE:New("Deep Strike Mission: Intel suggests that ammunition depots at the the Baluza Airfield in Egypt are being used to as a supply point for parts integral to manufacturing rockets.\n\n" ..
  "Metric: X+00104467 Z+00127135\nLat Long Standard: N 31* 0' 3\"   E 32*33'32\"\nLat Long Precise: N 31*00'3.07\"   E 32*33'32.89\"\nLat Long Decimal Minutes: N 31* 0.051'   E 32*33.548'\nMGRS GRID: 36 R VV 57912 29779\nAltitude: 37 m \ 120 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesBaluza2()
  MESSAGE:New("Deep Strike Mission: Intel suggests that ammunition depots at the the Baluza Airfield in Egypt are being used to as a supply point for parts integral to manufacturing rockets.\n\n" ..
  "Metric: X+00104488 Z+00127222\nLat Long Standard: N 31* 0' 3\"   E 32*33'36\"\nLat Long Precise: N 31*00'3.77\"   E 32*33'36.17\"\nLat Long Decimal Minutes: N 31* 0.062'   E 32*33.602'\nMGRS GRID: 36 R VV 57999 29801\nAltitude: 37 m \ 120 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesBaluza3()
  MESSAGE:New("Deep Strike Mission: Intel suggests that ammunition depots at the the Baluza Airfield in Egypt are being used to as a supply point for parts integral to manufacturing rockets.\n\n" ..
  "Metric: X+00104512 Z+00127318\nLat Long Standard: N 31* 0' 4\"   E 32*33'39\"\nLat Long Precise: N 31*00'4.56\"   E 32*33'39.79\"\nLat Long Decimal Minutes: N 31* 0.076'   E 32*33.663'\n\\nMGRS GRID: 36 R VV 58095 29825\nAltitude: 37 m \ 120 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesCatherine1()
  MESSAGE:New("Deep Strike Mission: Intel suggests that ammunition depots at the the Catherine Airfield in Egypt are being used to as a supply point for parts integral to manufacturing rockets.\n\n" ..
  "Metric: X-00151626 Z+00272648\nLat Long Standard: N 28*41'10\"   E 34* 3'31\"\nLat Long Precise: N 28*41'10.59\"   E 34*03'31.14\"\nLat Long Decimal Minutes: N 28*41.176'   E 34* 3.519'\nMGRS GRID: 36 R XS 03425 73687\nAltitude: 1297 m \ 4256 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesCatherine2()
  MESSAGE:New("Deep Strike Mission: Intel suggests that ammunition depots at the the Catherine Airfield in Egypt are being used to as a supply point for parts integral to manufacturing rockets.\n\n" ..
  "Metric: X-00152266 Z+00272812\nLat Long Standard: N 28*40'49\"   E 34* 3'36\"\nLat Long Precise: N 28*40'49.75\"   E 34*03'36.98\"\nLat Long Decimal Minutes: N 28*40.829'   E 34* 3.616'\nMGRS GRID: 36 R XS 03589 73047\nAltitude: 1297 m \ 4256 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesCatherine3()
  MESSAGE:New("Deep Strike Mission: Intel suggests that ammunition depots at the the Catherine Airfield in Egypt are being used to as a supply point for parts integral to manufacturing rockets.\n\n" ..
  "Metric: X-00151608 Z+00272371\nLat Long Standard: N 28*41'11\"   E 34* 3'20\"\nLat Long Precise: N 28*41'11.24\"   E 34*03'20.96\"\nLat Long Decimal Minutes: N 28*41.187'   E 34* 3.349'\nMGRS GRID: 36 R XS 03149 73704\nAltitude: 1319 m \ 4329 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end


function attack_hvt_bomb_1()
  MESSAGE:New("Gaza Strike Mission: Informats in Gaza have have provided confirmation of IED manufacturing taking place in a warehouse. Raise the building to the ground.\n\n" ..
  "Metric: X+00161984 Z+00306122\nLat Long Standard: N 31*30'44\"   E 34*26'30\"\nLat Long Precise: N 31*30'44.81\"   E 34*26'30.18\"\nLat Long Decimal Minutes: N 31*30.746'   E 34*26.503'\nMGRS GRID: 36 R XV 36900 87296\nAltitude: 32 m \ 106 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_hvt_bomb_2()
  MESSAGE:New("Gaza Strike Mission: Informats in Gaza have have provided confirmation of IED manufacturing taking place in a warehouse. Raise the building to the ground.\n\n" ..
  "Metric: X+00161869 Z+00306034\nLat Long Standard: N 31*30'41\"   E 34*26'26\"\nLat Long Precise: N 31*30'41.12\"   E 34*26'26.79\"\nLat Long Decimal Minutes: N 31*30.685'   E 34*26.446'\nMGRS GRID: 36 R XV 36812 87181\nAltitude: 31 m \ 101 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_hvt_bomb_3()
  MESSAGE:New("Gaza Strike Mission: Informats in Gaza have have provided confirmation of IED manufacturing taking place in a warehouse. Raise the building to the ground.\n\n" ..
  "Metric: X+00161681 Z+00305897\nLat Long Standard: N 31*30'35\"   E 34*26'21\"\nLat Long Precise: N 31*30'35.09\"   E 34*26'21.47\"\nLat Long Decimal Minutes: N 31*30.584'   E 34*26.357'\nMGRS GRID: 36 R XV 36674 86994\nAltitude: 28 m \ 92 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_rocket_factory1()
  MESSAGE:New("Gaza Strike Mission: Rocket Launch Deteced! Drones have monitored the luanching of rockets from this location. Raise the building to the ground.\n\n" ..
  "Metric: X+00164078 Z+00305924\nLat Long Standard: N 31*31'52\"   E 34*26'23\"\nLat Long Precise: N 31*31'52.88\"   E 34*26'23.73\"\nLat Long Decimal Minutes: N 31*31.881'   E 34*26.395'\nMGRS GRID: 36 R XV 36702 89390\nAltitude: 2 m \ 6 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_rocket_factory2()
  MESSAGE:New("Gaza Strike Mission: Rocket Launch Deteced! Drones have monitored the luanching of rockets from this location. Raise the building to the ground.\n\n" ..
  "Metric: X+00163089 Z+00305221\nLat Long Standard: N 31*31'21\"   E 34*25'56\"\nLat Long Precise: N 31*31'21.08\"   E 34*25'56.57\"\nLat Long Decimal Minutes: N 31*31.351'   E 34*25.942'\nMGRS GRID: 36 R XV 35999 88401\nAltitude: 5 m \ 15 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_rocket_factory3()
  MESSAGE:New("Gaza Strike Mission: Rocket Launch Deteced! Drones have monitored the luanching of rockets from this location. Raise the building to the ground.\n\n" ..
  "Metric: X+00163402 Z+00305438\nLat Long Standard: N 31*31'31\"   E 34*26' 4\"\nLat Long Precise: N 31*31'31.15\"   E 34*26'4.96\"\nLat Long Decimal Minutes: N 31*31.519'   E 34*26.082'\nMGRS GRID: 36 R XV 36216 88714\nAltitude: 4 m \ 13 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_rocket_factory4()
  MESSAGE:New("Gaza Strike Mission: Rocket Launch Deteced! Drones have monitored the luanching of rockets from this location. Raise the building to the ground.\n\n" ..
  "Metric: X+00163134 Z+00305260\nLat Long Standard: N 31*31'22\"   E 34*25'58\"\nLat Long Precise: N 31*31'22.52\"   E 34*25'58.07\"\nLat Long Decimal Minutes: N 31*31.375'   E 34*25.967'\nMGRS GRID: 36 R XV 36038 88446\nAltitude: 4 m \ 15 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_rocket_factory5()
  MESSAGE:New("Gaza Strike Mission: Rocket Launch Deteced! Drones have monitored the luanching of rockets from this location. Raise the building to the ground.\n\n" ..
  "Metric: X+00163181 Z+00305294\nLat Long Standard: N 31*31'24\"   E 34*25'59\"\nLat Long Precise: N 31*31'24.03\"   E 34*25'59.38\"\nLat Long Decimal Minutes: N 31*31.400'   E 34*25.989'\nMGRS GRID: 36 R XV 36071 88493\nAltitude: 4 m \ 13 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_rocket_factory6()
  MESSAGE:New("Gaza Strike Mission: Rocket Launch Deteced! Drones have monitored the luanching of rockets from this location. Raise the building to the ground.\n\n" ..
  "Metric: X+00163818 Z+00305752\nLat Long Standard: N 31*31'44\"   E 34*26'17\"\nLat Long Precise: N 31*31'44.52\"   E 34*26'17.06\"\nLat Long Decimal Minutes: N 31*31.742'   E 34*26.284'\nMGRS GRID: 36 R XV 36529 89130\nAltitude: 3 m / 10 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_fuel_stations1()
  MESSAGE:New("Gaza Strike Mission: Destroy the fuel supplies of the Hamas teorrists!\n\n" ..
  "Metric: X+00164342 Z+00306553\nLat Long Standard: N 31*32' 1\"   E 34*26'47\"\nLat Long Precise: N 31*32'1.21\"   E 34*26'47.70\"\nLat Long Decimal Minutes: N 31*32.020'   E 34*26.795'\nMGRS GRID: 36 R XV 37331 89655\nAltitude: 13 m \ 42 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_fuel_stations2()
  MESSAGE:New("Gaza Strike Mission: Destroy the fuel supplies of the Hamas teorrists!\n\n" ..
  "Metric: X+00158594 Z+00302976\nLat Long Standard: N 31*28'56\"   E 34*24'29\"\nLat Long Precise: N 31*28'56.08\"   E 34*24'29.27\"\nLat Long Decimal Minutes: N 31*28.934'   E 34*24.487'\nMGRS GRID: 36 R XV 33753 83907\nAltitude: 3 m \ 11 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function attack_fuel_stations3()
  MESSAGE:New("Gaza Strike Mission: Destroy the fuel supplies of the Hamas teorrists!\n\n" ..
  "Metric: X+00163864 Z+00313887\nLat Long Standard: N 31*31'42\"   E 34*31'25\"\nLat Long Precise: N 31*31'42.44\"   E 34*31'25.48\"\nLat Long Decimal Minutes: N 31*31.707'   E 34*31.424'\nMGRS GRID: 36 R XV 44665 89176\nAltitude: 33 m \ 110 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Hamas_Leaders1()
  MESSAGE:New("Gaza Strike Mission: Hamas Leadership found! Highly paid informats have confrimed the location a high ranking Hamas militant. Located in a highly populated area. Percision weapons must be used to keep civilian casualties at a minimum.\n\n" ..
  "Metric: X+00163739 Z+00307467\nLat Long Standard: N 3131'41\"   E 34*27'22\"\nLat Long Precise: N 31*31'41.22\"   E 34*27'22.02\"\nLat Long Decimal Minutes: N 31*31.687'   E 34*27.367'\nMGRS GRID: 36 R XV 38244 89051\nAltitude: 46 m \ 150 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Hamas_Leaders2()
  MESSAGE:New("Gaza Strike Mission: Hamas Leadership found! Highly paid informats have confrimed the location a high ranking Hamas militant. Located in a highly populated area. Percision weapons must be used to keep civilian casualties at a minimum.\n\n" ..
  "Metric: X+00164647 Z+00307179\nLat Long Standard: N 31*32'10\"   E 34*27'11\"\nLat Long Precise: N 31*32'10.82\"   E 34*27'11.56\"\nLat Long Decimal Minutes: N 31*32.180'   E 34*27.192'\nMGRS GRID: 36 R XV 37956 89959\nAltitude: 19 m \ 63 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Hamas_Leaders3()
  MESSAGE:New("Gaza Strike Mission: Hamas Leadership found! Highly paid informats have confrimed the location a high ranking Hamas militant. Located in a highly populated area. Percision weapons must be used to keep civilian casualties at a minimum.\n\n" ..
  "Metric: X+00163109 Z+00306375\nLat Long Standard: N 31*31'21\"   E 34*26'40\"\nLat Long Precise: N 31*31'21.23\"   E 34*26'40.31\"\nLat Long Decimal Minutes: N 31*31.353'   E 34*26.671'\nMGRS GRID: 36 R XV 37152 88421\nAltitude: 30 m \ 97 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Hamas_Leaders4()
  MESSAGE:New("Gaza Strike Mission: Hamas Leadership found! Highly paid informats have confrimed the location a high ranking Hamas militant. Located in a highly populated area. Percision weapons must be used to keep civilian casualties at a minimum.\n\n" ..
  "Metric: X+00143987 Z+00292295\nLat Long Standard: N 31*21' 6\"   E 34*17'38\"\nLat Long Precise: N 31*21'6.02\"   E 34*17'38.06\"\nLat Long Decimal Minutes: N 31*21.100'   E 34*17.634'\nMGRS GRID: 36 R XV 23073 69300\nAltitude: 42 m \ 137 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez1()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038600 Z+00182000\nLat Long Standard: N 30*24'25\"   E 33* 7'58\"\nLat Long Precise: N 30*24'25.85\"   E 33*07'58.92\"\nLat Long Decimal Minutes: N 30*24.430'   E 33* 7.982'\nMGRS GRID: 36 R WU 12778 63913\nAltitude: 307 m / 1007 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez1()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038597 Z+00181390\nLat Long Standard: N 30*24'25\"   E 33* 7'36\"\nLat Long Precise: N 30*24'25.76\"   E 33*07'36.06\"\nLat Long Decimal Minutes: N 30*24.429'   E 33* 7.601'\nMGRS GRID: 36 R WU 12168 63909\nAltitude: 310 m / 1016 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez2()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038600 Z+00182000\nLat Long Standard: N 30*24'25\"   E 33* 7'58\"\nLat Long Precise: N 30*24'25.85\"   E 33*07'58.92\"\nLat Long Decimal Minutes: N 30*24.430'   E 33* 7.982'\nMGRS GRID: 36 R WU 12778 63913\nAltitude: 307 m / 1007 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez3()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038390 Z+00181961\nLat Long Standard: N 30*24'19\"   E 33* 7'57\"\nLat Long Precise: N 30*24'19.02\"   E 33*07'57.44\"\nLat Long Decimal Minutes: N 30*24.317'   E 33* 7.957'\nMGRS GRID: 36 R WU 12739 63702\nAltitude: 308 m / 1011 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez4()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038219 Z+00181872\nLat Long Standard: N 30*24'13\"   E 33* 7'54\"\nLat Long Precise: N 30*24'13.46\"   E 33*07'54.09\"\nLat Long Decimal Minutes: N 30*24.224'   E 33* 7.901'\nMGRS GRID: 36 R WU 12649 63531\nAltitude: 310 m / 1017 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez5()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038058 Z+00181667\nLat Long Standard: N 30*24' 8\"   E 33* 7'46\"\nLat Long Precise: N 30*24'8.25\"   E 33*07'46.40\"\nLat Long Decimal Minutes: N 30*24.137'   E 33* 7.773'\nMGRS GRID: 36 R WU 12444 63371\nAltitude: 314 m / 1030 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez6()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00037990 Z+00181404\nLat Long Standard: N 30*24' 6\"   E 33* 7'36\"\nLat Long Precise: N 30*24'6.05\"   E 33*07'36.57\"\nLat Long Decimal Minutes: N 30*24.100'   E 33* 7.609'\nMGRS GRID: 36 R WU 12182 63303\nAltitude: 316 m / 1036 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez7()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038022 Z+00181201\nLat Long Standard: N 30*24' 7\"   E 33* 7'28\"\nLat Long Precise: N 30*24'7.11\"   E 33*07'28.94\"\nLat Long Decimal Minutes: N 30*24.118'   E 33* 7.482'\nMGRS GRID: 36 R WU 11979 63335\nAltitude: 315 m / 1034 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez8()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038131 Z+00180997\nLat Long Standard: N 30*24'10\"   E 33* 7'21\"\nLat Long Precise: N 30*24'10.63\"   E 33*07'21.29\"\nLat Long Decimal Minutes: N 30*24.177'   E 33* 7.354'\nMGRS GRID: 36 R WU 11774 63443\nAltitude: 317 m / 1038 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez9()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038348 Z+00180836\nLat Long Standard: N 30*24'17\"   E 33* 7'15\"\nLat Long Precise: N 30*24'17.70\"   E 33*07'15.29\"\nLat Long Decimal Minutes: N 30*24.295'   E 33* 7.254'\nMGRS GRID: 36 R WU 11614 63661\nAltitude: 316 m / 1037 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez10()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038611 Z+00180780\nLat Long Standard: N 30*24'26\"   E 33* 7'13\"\nLat Long Precise: N 30*24'26.26\"   E 33*07'13.18\"\nLat Long Decimal Minutes: N 30*24.437'   E 33* 7.219'\nMGRS GRID: 36 R WU 11557 63924\nAltitude: 314 m / 1031 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez11()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038875 Z+00180853\nLat Long Standard: N 30*24'34\"   E 33* 7'15\"\nLat Long Precise: N 30*24'34.80\"   E 33*07'15.93\"\nLat Long Decimal Minutes: N 30*24.580'   E 33* 7.265'\nMGRS GRID: 36 R WU 11630 64187\nAltitude: 313 m / 1026 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez12()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00039063 Z+00180998\nLat Long Standard: N 30*24'40\"   E 33* 7'21\"\nLat Long Precise: N 30*24'40.91\"   E 33*07'21.39\"\nLat Long Decimal Minutes: N 30*24.681'   E 33* 7.356'\nMGRS GRID: 36 R WU 11776 64375\nAltitude: 310 m / 1017 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez13()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00039168 Z+00181186\nLat Long Standard: N 30*24'44\"   E 33* 7'28\"\nLat Long Precise: N 30*24'44.34\"   E 33*07'28.45\"\nLat Long Decimal Minutes: N 30*24.739'   E 33* 7.474'\nMGRS GRID: 36 R WU 11964 64481\nAltitude: 307 m / 1009 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez14()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00039201 Z+00181396\nLat Long Standard: N 30*24'45\"   E 33* 7'36\"\nLat Long Precise: N 30*24'45.40\"   E 33*07'36.29\"\nLat Long Decimal Minutes: N 30*24.756'   E 33* 7.604'\nMGRS GRID: 36 R WU 12173 64514\nAltitude: 307 m / 1006 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez15()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00039151 Z+00181645\nLat Long Standard: N 30*24'43\"   E 33* 7'45\"\nLat Long Precise: N 30*24'43.75\"   E 33*07'45.65\"\nLat Long Decimal Minutes: N 30*24.729'   E 33* 7.760'\nMGRS GRID: 36 R WU 12423 64463\nAltitude: 306 m / 1004 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function DeepStrikesMelez16()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00039025 Z+00181826\nLat Long Standard: N 30*24'39\"   E 33* 7'52\"\nLat Long Precise: N 30*24'39.65\"   E 33*07'52.40\"\nLat Long Decimal Minutes: N 30*24.660'   E 33* 7.873'\nMGRS GRID: 36 R WU 12603 64337\nAltitude: 306 m / 1005 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end  

function DeepStrikesMelez17()
  MESSAGE:New("A massive comms center at the Melez airbase is being used to facilitate communications and coordination between the various factions arrayed against Israel. Destroy as many towers as you can! Resistance is unknown but expected to be high.\n\n" ..
  "Metric: X+00038815 Z+00181957\nLat Long Standard: N 30*24'32\"   E 33* 7'57\"\nLat Long Precise: N 30*24'32.84\"   E 33*07'57.33\"\nLat Long Decimal Minutes: N 30*24.547'   E 33* 7.955'\nMGRS GRID: 36 R WU 12735 64128\nAltitude: 306 m / 1004 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function insurgent_tunnels1()
  MESSAGE:New("An extensive labyrinth of tunnels built by the Hamas militant group stretches across the densely populated strip, hiding fighters and their rocket arsenal. A fortified entrance has been discovered at the following location:\n\n" ..
  "Metric: X+00142427 Z+00301902\nLat Long Standard: N 31*20'11\"   E 34*23'40\"\nLat Long Precise: N 31*20'11.54\"   E 34*23'40.83\"\nLat Long Decimal Minutes: N 31*20.192'   E 34*23.680'\nMGRS GRID: 36 R XV 32680 67739\nAltitude: 104 m / 343 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function insurgent_tunnels2()
  MESSAGE:New("An extensive labyrinth of tunnels built by the Hamas militant group stretches across the densely populated strip, hiding fighters and their rocket arsenal. A fortified entrance has been discovered at the following location:\n\n" ..
  "Metric: X+00135345 Z+00301396\nLat Long Standard: N 31*16'21\"   E 34*23'18\"\nLat Long Precise: N 31*16'21.77\"   E 34*23'18.30\"\nLat Long Decimal Minutes: N 31*16.362'   E 34*23.305'\nMGRS GRID: 36 R XV 32174 60657\nAltitude: 97 m / 317 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function insurgent_tunnels3()
  MESSAGE:New("An extensive labyrinth of tunnels built by the Hamas militant group stretches across the densely populated strip, hiding fighters and their rocket arsenal. A fortified entrance has been discovered at the following location:\n\n" ..
  "Metric: X+00153695 Z+00314716\nLat Long Standard: N 31*26'11\"   E 34*31'51\"\nLat Long Precise: N 31*26'11.88\"   E 34*31'51.49\"\nLat Long Decimal Minutes: N 31*26.198'   E 34*31.858'\nMGRS GRID: 36 R XV 45493 79007\nAltitude: 86 m / 283 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function insurgent_tunnels4()
  MESSAGE:New("An extensive labyrinth of tunnels built by the Hamas militant group stretches across the densely populated strip, hiding fighters and their rocket arsenal. A fortified entrance has been discovered at the following location:\n\n" ..
  "Metric: X+00126467 Z+00296070\nLat Long Standard: N 31*11'35\"   E 34*19'52\"\nLat Long Precise: N 31*11'35.62\"   E 34*19'52.90\"\nLat Long Decimal Minutes: N 31*11.593'   E 34*19.881'\nMGRS GRID: 36 R XV 26848 51780\nAltitude: 114 m / 373 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end


function aid_refugee1()
  MESSAGE:New("Find medical supply containers and deliver to the refugee camp."
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp1T1()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00140357 Z+00295331\nLat Long Standard: N 31*19' 6\"   E 34*19'31\"\nLat Long Precise: N 31*19'6.96\"   E 34*19'31.27\"\nLat Long Decimal Minutes: N 31*19.116'   E 34*19.521'\nMGRS GRID: 36 R XV 26108 65670\nAltitude: 51 m / 169 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp1T2()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00140421 Z+00295347\nLat Long Standard: N 31*19' 9\"   E 34*19'31\"\nLat Long Precise: N 31*19'9.02\"   E 34*19'31.91\"\nLat Long Decimal Minutes: N 31*19.150'   E 34*19.531'\nMGRS GRID: 36 R XV 26125 65733\nAltitude: 52 m / 170 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp1T3()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00140342 Z+00295263\nLat Long Standard: N 31*19' 6\"   E 34*19'28\"\nLat Long Precise: N 31*19'6.51\"   E 34*19'28.70\"\nLat Long Decimal Minutes: N 31*19.108'   E 34*19.478'\nMGRS GRID: 36 R XV 26041 65655\nAltitude: 51 m / 166 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp1T4()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00140311 Z+00295295\nLat Long Standard: N 31*19' 5\"   E 34*19'29\"\nLat Long Precise: N 31*19'5.49\"   E 34*19'29.89\"\nLat Long Decimal Minutes: N 31*19.091'   E 34*19.498'\nMGRS GRID: 36 R XV 26072 65624\nAltitude: 51 m / 167 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp2T1()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00135990 Z+00294496\nLat Long Standard: N 31*16'45\"   E 34*18'57\"\nLat Long Precise: N 31*16'45.48\"   E 34*18'57.72\"\nLat Long Decimal Minutes: N 31*16.758'   E 34*18.962'\nMGRS GRID: 36 R XV 25274 61303\nAltitude: 41 m / 133 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp2T2()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00135962 Z+00294508\nLat Long Standard: N 31*16'44\"   E 34*18'58\"\nLat Long Precise: N 31*16'44.56\"   E 34*18'58.17\"\nLat Long Decimal Minutes: N 31*16.742'   E 34*18.969'\nMGRS GRID: 36 R XV 25286 61275\nAltitude: 41 m / 133 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp2T3()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00135880 Z+00294487\nLat Long Standard: N 31*16'41\"   E 34*18'57\"\nLat Long Precise: N 31*16'41.91\"   E 34*18'57.34\"\nLat Long Decimal Minutes: N 31*16.698'   E 34*18.955'\nMGRS GRID: 36 R XV 25265 61193\nAltitude: 41 m / 134 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp2T4()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00135900 Z+00294527\nLat Long Standard: N 31*16'42\"   E 34*18'58\"\nLat Long Precise: N 31*16'42.54\"   E 34*18'58.83\"\nLat Long Decimal Minutes: N 31*16.709'   E 34*18.980'\nMGRS GRID: 36 R XV 25304 61213\nAltitude: 41 m / 133 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp2T5()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00135831 Z+00294499\nLat Long Standard: N 31*16'40\"   E 34*18'57\"\nLat Long Precise: N 31*16'40.30\"   E 34*18'57.77\"\nLat Long Decimal Minutes: N 31*16.671'   E 34*18.962'\nMGRS GRID: 36 R XV 25277 61143\nAltitude: 41 m / 134 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function Training_Camp2T6()
  MESSAGE:New("A terrorist training camp has been discovered in the Gaza strip. Destroy the entire site! An active building is still standing at:\n\n" ..
  "Metric: X+00135850 Z+00294542\nLat Long Standard: N 31*16'40\"   E 34*18'59\"\nLat Long Precise: N 31*16'40.91\"   E 34*18'59.40\"\nLat Long Decimal Minutes: N 31*16.681'   E 34*18.990'\nMGRS GRID: 36 R XV 25320 61162\nAltitude: 41 m / 134 feet"
  , mission_msg_time, "PROGRESS", false):ToBlue()
end


function aid_refugee1_marklocation()

  -- Define the message and the repeat interval
  local message = "South Gaza medical supplies have been flared in yellow. Deliver to South Gaza refugee camp flared in green. Flares will last 30 seconds.\n\nCompletion of a delivery will grant reinforcements.."
  local interval = 5 -- in seconds
  MESSAGE:New(message, msgTime, "Refugee Camp Flare", false):ToBlue()
  -- Define the RefugeeFlareScheduler1 function
  local function RefugeeFlareScheduler1()
      local startTime = timer.getTime()
      local function repeatMessage()
          local currentTime = timer.getTime()
          if currentTime - startTime <= 30 then
              Refugee_Zone_1:FlareZone(FLARECOLOR.Green, 4)
              Medical_Supplies_1:FlareZone(FLARECOLOR.Yellow, 4)
              timer.scheduleFunction(repeatMessage, nil, timer.getTime() + interval)
          end
      end
      repeatMessage()
  end
  -- Start the RefugeeFlareScheduler1
  RefugeeFlareScheduler1()

end


function aid_refugee2()
  MESSAGE:New("Find medical supply containers and deliver to the refugee camp in the town of Netivot."
  , mission_msg_time, "PROGRESS", false):ToBlue()
end

function aid_refugee2_marklocation()

  -- Define the message and the repeat interval
  local message = "Netivot medical supplies have been flared in yellow. Deliver to refugee station flared in green. Flares will last 30 seconds.\n\nCompletion of a delivery will grant reinforcements.."
  MESSAGE:New(message, msgTime, "Refugee Camp Flare", false):ToBlue()
  local interval = 5 -- in seconds
  
  -- Define the RefugeeFlareScheduler1 function
  local function RefugeeFlareScheduler2()
      local startTime = timer.getTime()
      local function repeatMessage()
          local currentTime = timer.getTime()
          if currentTime - startTime <= 30 then
              Refugee_Zone_2:FlareZone(FLARECOLOR.Green, 4)
              Medical_Supplies_2:FlareZone(FLARECOLOR.Yellow, 4)
              timer.scheduleFunction(repeatMessage, nil, timer.getTime() + interval)
          end
      end
      repeatMessage()
  end
  -- Start the RefugeeFlareScheduler1
  RefugeeFlareScheduler2()
end


MenuBlue = MENU_COALITION:New(coalition.side.BLUE, "TACTICAL MISSIONS")

--Add Deep Strike Menu Items
MenuBlue_DeepStrikes = MENU_COALITION:New(coalition.side.BLUE, "MISSIONS:Long Range Strikes", MenuBlue)

MenuBLUE_DeepStrikesBaluza = MENU_COALITION:New(coalition.side.BLUE, "Baluza Amunition Depots", MenuBlue_DeepStrikes)
MenuBlue_DeepStrikesBaluza1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Baluza Amunition Depots 1", MenuBLUE_DeepStrikesBaluza, DeepStrikesBaluza1)
MenuBlue_DeepStrikesBaluza2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Baluza Amunition Depots 2", MenuBLUE_DeepStrikesBaluza, DeepStrikesBaluza2)
MenuBlue_DeepStrikesBaluza3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Baluza Amunition Depots 3", MenuBLUE_DeepStrikesBaluza, DeepStrikesBaluza3)

MenuBLUE_DeepStrikesCatherine = MENU_COALITION:New(coalition.side.BLUE, "Catherine Amunition Depots", MenuBlue_DeepStrikes)
MenuBlue_DeepStrikesCatherine1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Catherine Amunition Depots 1", MenuBLUE_DeepStrikesCatherine, DeepStrikesCatherine1)
MenuBlue_DeepStrikesCatherine2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Catherine Amunition Depots 2", MenuBLUE_DeepStrikesCatherine, DeepStrikesCatherine2)
MenuBlue_DeepStrikesCatherine3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Catherine Amunition Depots 3", MenuBLUE_DeepStrikesCatherine, DeepStrikesCatherine3)

MenuBLUE_DeepStrikesMelez = MENU_COALITION:New(coalition.side.BLUE, "Melez Coms Center", MenuBlue_DeepStrikes)
MenuBlue_DeepStrikesMelez1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 1", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez1)
MenuBlue_DeepStrikesMelez2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 2", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez2)
MenuBlue_DeepStrikesMelez3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 3", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez3)
MenuBlue_DeepStrikesMelez4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 4", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez4)
MenuBlue_DeepStrikesMelez5 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 5", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez5)
MenuBlue_DeepStrikesMelez6 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 6", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez6)
MenuBlue_DeepStrikesMelez7 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 7", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez7)
MenuBlue_DeepStrikesMelez8 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 8", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez8)
MenuBlue_DeepStrikesMelez9 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 9", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez9)
MenuBlue_DeepStrikesMelez10 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 10", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez10)
MenuBlue_DeepStrikesMelez11 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 11", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez11)
MenuBlue_DeepStrikesMelez12 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 12", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez12)
MenuBlue_DeepStrikesMelez13 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 13", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez13)
MenuBlue_DeepStrikesMelez14 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 14", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez14)
MenuBlue_DeepStrikesMelez15 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 15", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez15)
MenuBlue_DeepStrikesMelez16 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 16", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez16)
MenuBlue_DeepStrikesMelez17 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Tower 17", MenuBLUE_DeepStrikesMelez, DeepStrikesMelez17)



-- Add Gaza Strike Menu Items
MenuBlue_HVT = MENU_COALITION:New(coalition.side.BLUE, "MISSIONS:Gaza High Value Targets (HVT)", MenuBlue)
MenuBLUE_HVTBomb = MENU_COALITION:New(coalition.side.BLUE, "IED Factories", MenuBlue_HVT)
MenuBLUE_HVTHamasLeaders = MENU_COALITION:New(coalition.side.BLUE, "Hamas Leaders", MenuBlue_HVT)  
MenuBLUE_RocketSites = MENU_COALITION:New(coalition.side.BLUE, "Rocket Production Sites", MenuBlue_HVT)
MenuBLUE_FuelStations = MENU_COALITION:New(coalition.side.BLUE,"Fuel Stations", MenuBlue_HVT)
MenuBLUE_Insurgent_Tunnels = MENU_COALITION:New(coalition.side.BLUE,"Insurgent Tunnels", MenuBlue_HVT)
MenuBLUE_Training_Camps = MENU_COALITION:New(coalition.side.BLUE,"Training Camps", MenuBlue_HVT)


MenuBlue_HamasLeadership1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Hamas Leadership 1", MenuBLUE_HVTHamasLeaders, Hamas_Leaders1)
MenuBlue_HamasLeadership2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Hamas Leadership 2", MenuBLUE_HVTHamasLeaders, Hamas_Leaders3)
MenuBlue_HamasLeadership3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Hamas Leadership 3", MenuBLUE_HVTHamasLeaders, Hamas_Leaders4)

MenuBlue_HVTBomb1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy IED Factory 1", MenuBLUE_HVTBomb, attack_hvt_bomb_1) 
MenuBlue_HVTBomb2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy IED Factory 2", MenuBLUE_HVTBomb, attack_hvt_bomb_2)
MenuBlue_HVTBomb3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy IED Factory 3", MenuBLUE_HVTBomb, attack_hvt_bomb_3)

MenuBlue_HVTRocket1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Rocket Factory 1", MenuBLUE_RocketSites, attack_rocket_factory1)
MenuBlue_HVTRocket2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Rocket Factory 2", MenuBLUE_RocketSites, attack_rocket_factory2)
MenuBlue_HVTRocket3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Rocket Factory 3", MenuBLUE_RocketSites, attack_rocket_factory3)
MenuBlue_HVTRocket4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Rocket Factory 4", MenuBLUE_RocketSites, attack_rocket_factory4)
MenuBlue_HVTRocket5 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Rocket Factory 5", MenuBLUE_RocketSites, attack_rocket_factory5)
MenuBlue_HVTRocket6 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Destroy Rocket Factory 6", MenuBLUE_RocketSites, attack_rocket_factory6)

MenuBlue_FuelStation1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Destroy Fuel Supply 1", MenuBLUE_FuelStations, attack_fuel_stations1)
MenuBlue_FuelStation2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Destroy Fuel Supply 2", MenuBLUE_FuelStations, attack_fuel_stations2)
MenuBlue_FuelStation3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Destroy Fuel Supply 3", MenuBLUE_FuelStations, attack_fuel_stations3)

MenuBLUE_Insurgent_Tunnels1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Insurgent Tunnel 1", MenuBLUE_Insurgent_Tunnels, insurgent_tunnels1)
MenuBLUE_Insurgent_Tunnels2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Insurgent Tunnel 2", MenuBLUE_Insurgent_Tunnels, insurgent_tunnels2)
MenuBLUE_Insurgent_Tunnels3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Insurgent Tunnel 3", MenuBLUE_Insurgent_Tunnels, insurgent_tunnels3)
MenuBLUE_Insurgent_Tunnels4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Insurgent Tunnel 4", MenuBLUE_Insurgent_Tunnels, insurgent_tunnels4)




-- Add Gaza Humanitarian Missions
MenuBlue_RefugeeCamaps = MENU_COALITION:New(coalition.side.BLUE, "MISSIONS: Aid Refugee Camps", MenuBlue)
MenuBlue_RefugeeCamap1 = MENU_COALITION:New(coalition.side.BLUE, "Medical Supplies (South Gaza)", MenuBlue_RefugeeCamaps)
MenuBlue_RefugeeCamapMedSupplies1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Objective Summary", MenuBlue_RefugeeCamap1, aid_refugee1)
MenuBlue_RefugeeCamapMedSupplies1Location = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Mark Location", MenuBlue_RefugeeCamap1, aid_refugee1_marklocation)

MenuBlue_RefugeeCamap2 = MENU_COALITION:New(coalition.side.BLUE, "Medical Supplies (Netivot)", MenuBlue_RefugeeCamaps)
MenuBlue_RefugeeCamapMedSupplies2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Objective Summary", MenuBlue_RefugeeCamap2, aid_refugee2)
MenuBlue_RefugeeCamapMedSupplies2Location = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Mark Location", MenuBlue_RefugeeCamap2, aid_refugee2_marklocation)

MenuBLUE_Training_Camp1 = MENU_COALITION:New(coalition.side.BLUE,"Training Camp 1", MenuBLUE_Training_Camps)
MenuBlue_Training_Camp1T1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 1", MenuBLUE_Training_Camp1, Training_Camp1T1)
MenuBlue_Training_Camp1T2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 2", MenuBLUE_Training_Camp1, Training_Camp1T2)
MenuBlue_Training_Camp1T3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 3", MenuBLUE_Training_Camp1, Training_Camp1T3)
MenuBlue_Training_Camp1T4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 4", MenuBLUE_Training_Camp1, Training_Camp1T4)



MenuBLUE_Training_Camp2 = MENU_COALITION:New(coalition.side.BLUE,"Training Camp 2", MenuBLUE_Training_Camps)
MenuBlue_Training_Camp2T1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 1", MenuBLUE_Training_Camp2, Training_Camp2T1)
MenuBlue_Training_Camp2T2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 2", MenuBLUE_Training_Camp2, Training_Camp2T2)
MenuBlue_Training_Camp2T3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 3", MenuBLUE_Training_Camp2, Training_Camp2T3)
MenuBlue_Training_Camp2T4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 4", MenuBLUE_Training_Camp2, Training_Camp2T4)
MenuBlue_Training_Camp2T5 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 5", MenuBLUE_Training_Camp2, Training_Camp2T5)
MenuBlue_Training_Camp2T6 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"Target 6", MenuBLUE_Training_Camp2, Training_Camp2T6)













