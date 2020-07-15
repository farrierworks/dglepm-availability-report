# DGLEPM Availability Report

![GitHub repo size](https://img.shields.io/github/repo-size/farrierworks/dglepm_drf_availability_report)
![GitHub top language](https://img.shields.io/github/languages/top/farrierworks/dglepm_drf_availability_report)
![GitHub last commit](https://img.shields.io/github/last-commit/farrierworks/dglepm_drf_availability_report)

## Description

The DGLEPM Availability Report is produced quarterly (or on demand), primarily in support of the equipment availability metric in the Defence Results Framework/Report (DRF/DRR). Secondarily, it may be used by others within or outside of the Division (e.g. 202 WD LMA Team Lead, ADM (Mat) J3 Ops), etc.). The demand for data products has increased over the past 10 months.

The Report includes 19 DRF "key" fleets:
* Leo 2 AEV
* Leo 2 ARV
* Leo 2 MBT
* LAV II Bison
* LAV II Coyote
* LAV III
* LAV 6.0
* M113A2
* M113A3
* M577A3
* TLAV MT
* M777
* AHSVS
* HLVW
* LSVW
* LUVW SMP
* MLVW
* MSVS SMP

In the context of DRF, equipment is said to be "unavailable" if it's:
1. Grounded due to Land Materiel Assurance issues
2. Grounded awaiting zero-stock nationally-procured/centrally-managed repair parts
3. At 202 WD or industry for 3rd/4th line repairs

The Report production process was automated by Capt Southcott, DLEPS 3 (with input from Capt Yogendran, DLEPS 6), using Python (a popular interpreted programming language). It uses DRMIS data, which can be accessed by anyone with MA&S Staff Officer access.

To produce the report, follow the steps below.

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
