# DGLEPM Availability Report

## Description

## Steps

1. In DRMIS production, run the following transactions with the following parameters:

 1. "IE 36 - Display Vehicles"
  1. Class Type: `002`
  2. Class: `VEH_EQUIP`
  3. Vehicle Type: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`

 2. "ZEIW29 - List Edit Display Notification (UDF)"
  1. Notification status: `Outstanding`, `Postponed` and `In process`
  2. Planning plant: `0001`
  3. Add `Equipment` column
 
2. In DRMIS BEx Analyzer (DRMIS BW Production), run the following transactions with the following parameters:
 
 1. "\[ZPM_0EQUIPMENT_7028_Q01\] VOR Tactical - MPO Disposition"
  1. Force Element Hierarchy: `\[3663\] Minister of National Defence` and `\[REST_H\] Not Assaigned Force Element`
  2. Equip. Object Type: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`
  3. Master Equip Index: `X`
