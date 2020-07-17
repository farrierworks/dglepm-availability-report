# DGLEPM Availability Report

![GitHub repo size](https://img.shields.io/github/repo-size/farrierworks/dglepm_drf_availability_report)
![GitHub top language](https://img.shields.io/github/languages/top/farrierworks/dglepm_drf_availability_report)
![GitHub last commit](https://img.shields.io/github/last-commit/farrierworks/dglepm_drf_availability_report)

## Description

The DGLEPM Availability Report is produced quarterly (or on demand), primarily in support of the equipment availability metric in the Defence Results Framework/Report (DRF/DRR). Secondarily, it may be used by others within or outside of the Division (e.g. 202 WD LMA Team Lead, ADM (Mat) J3 Ops), etc.). DGLEPM Ops has observed an increase in demand for data products within ADM (Mat) and the CA over the past 10 months.

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
1. Grounded due to Land Materiel Assurance (LMA) issues
   * DGLEPM Ops should know this intuitively due to its proximity to the LMA process
2. Grounded awaiting zero-stock nationally-procured/centrally-managed repair parts
   * An imperfect process was devised by Capt Southcott and the DRMIS PM SME, DLEPS 6, to find this by running a number of transactions in sequence (the process needs to be further refined)
3. At 202 WD or industry for 3rd/4th line repairs
   * Found by looking at open notifications in Plant 0001 (202 WD)

The report production process was significantly shortened/simplified by Capt Southcott, DLEPS 3 (with input from Capt Yogendran, DLEPS 6), using Python (a popular interpreted programming language). It uses DRMIS data, which can be accessed by anyone with MA&S Staff Officer access.

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
 
    * **"[ZPM_0EQUIPMENT_7028_Q01] VOR Tactical - MPO Disposition"**
        * Force Element Hierarchy: `[3663] Minister of National Defence` and `[REST_H] Not Assigned Force Element`
        * Equip. Object Type: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`
        * Master Equip Index: `X`

5. Export the results to Excel, and save the file to your USB drive as `vor_tactical_mpo_disposition.xlsx`.

6. Disconnect your USB drive from your DWAN computer and connect it to your standalone computer (e.g. Dell XPS 13).

7. On your standalone computer, create the following directories (folders):
    * `/home/{user}/Desktop/dglepm-availability-report`
    * `/home/{user}/Desktop/dglepm-availability-report/infiles`
    * `/home/{user}/Desktop/dglepm-availability-report/outfiles`
  
8. Clone the repository from GitHub to your standalone computer. Copy the URL to the `.git` file by clicking the "Code" button, followed by the "Clipboard" icon. Open Terminal (or Git Bash), navigate to the PycharmProjects directory (`/home/{user}/PycharmProjects/`), type `git clone ` (include a trailing space), paste the copied URL and press the `Enter` key. You should now have a local copy of the repository.

9. Copy and paste the 3 files from your USB drive to the following directory: `/home/{user}/Desktop/dglepm-availability-report/infiles/`.

10. Open PyCharm and select the `dglepm-availability-report` project. In `dglepmAvailabilityReport.py`, change the `user` variable (line 8) to your standalone computer username. Click the green "Run" button in the top right-hand corner.

11. Wait until the program finishes executing (approximately 10 seconds), and navigate to the following directory: `/home/{user}/Desktop/dglepm-availability-report/outfiles/`.

12. Copy and paste the report file to your USB drive.
