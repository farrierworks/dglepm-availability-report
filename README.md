# DGLEPM Availability Report

## Description

## Steps

1. Connect your USB drive to your DWAN computer.

2. In DRMIS production, run the following transactions with the specified parameters:

    * **"IE 36 - Display Vehicles"**
        * Class Type: `002`
        * Class: `VEH_EQUIP`
        * Vehicle Type: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`

    * **"ZEIW29 - List Edit Display Notification (UDF)"**
        * Notification status: `Outstanding`, `Postponed` and `In process`
        * Planning plant: `0001`
        * Add `Equipment` column
 
3. Export the results to Excel, and save the files to your USB drive as `ie36.xlsx` and `zeiw29.xlsx`, respectively.

4. In DRMIS BEx Analyzer (DRMIS BW Production), run the following transactions with the specified parameters:
 
    * **"\[ZPM_0EQUIPMENT_7028_Q01\] VOR Tactical - MPO Disposition"**
        * Force Element Hierarchy: `\[3663\] Minister of National Defence` and `\[REST_H\] Not Assaigned Force Element`
        * Equip. Object Type: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`
        * Master Equip Index: `X`

5. Export the results to Excel, and save the file to your USB drive as `vor_tactical_mpo_disposition.xlsx`.

6. Disconnect your USB drive from your DWAN computer and connect it to your standalone computer (Dell XPS 13).

7. Copy and paste the 3 files from your USB drive to the following directory: `/home/{user}/Desktop/dglepm_drf_availability_report/infiles/`.

8. Open PyCharm, select the `dglepm_drf_availability_report` project, and click the green "Run" button in the top right-hand corner.

9. Wait until the program finishes executing (approximately 10 seconds), and navigate to the following directory: `/home/{user}/Desktop/dglepm_drf_availability_report/outfiles/`.

10. Copy and paste the report file to your USB drive.
