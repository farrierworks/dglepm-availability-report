# DGLEPM Availability Report

![GitHub repo size](https://img.shields.io/github/repo-size/farrierworks/dglepm_drf_availability_report)
![GitHub top language](https://img.shields.io/github/languages/top/farrierworks/dglepm_drf_availability_report)
![GitHub last commit](https://img.shields.io/github/last-commit/farrierworks/dglepm_drf_availability_report)

## Description

The Director General Land Equipment Program Management (DGLEPM) Availability Report is produced quarterly (or on demand), primarily in support of the land equipment availability key performance indicator in the Department of National Defence Departmental Results Framework/Report (DRF/DRR). Secondarily, it may be used by others within or outside of DGLEPM (e.g. 202 WD LMA Team Lead, ADM (Mat) J3 Ops)). Over the past 11 months, there's been an increase in the demand for data products within ADM (Mat) and the CA.

The report includes 18 platforms, which comprise the 9 "key" fleets identified in the DRF:
1. Leo 2 AEV
2. Leo 2 ARV
3. Leo 2 MBT
4. LAV II Bison
5. LAV II Coyote
6. LAV III
7. LAV 6.0
8. TAPV
9. M113A3
10. M577A3
11. TLAV MT
12. M777
13. AHSVS
14. HLVW
15. LSVW
16. LUVW SMP
17. MLVW
18. MSVS SMP

In the context of the DRF, equipment is said to be "unavailable" if it's:
1. Grounded due to LMA issues
   * DGLEPM Ops should know this intuitively due to its involvement in the LMA process
2. Grounded awaiting zero-stock nationally-procured/centrally-managed repair parts
   * Currently, no way of finding this without consulting EMTs exists (due to the fact that serviceability status is tied to work orders, not maintenance activities)
3. At 202 WD/industry for 3rd/4th line repairs
   * Found by looking at open notifications in Plant 0001 (202 WD)

The report production process was significantly shortened/simplified by Capt Southcott, DLEPS 3, with input from Capt Yogendran, DLEPS 6, using Python (a popular interpreted scripting language). It uses Defence Resource Management Information System (DRMIS) data, which can be accessed by anyone with role Materiel Acquisition and Support Staff Officer.

To produce the report, follow the steps below.

## Steps

1. Connect your USB drive to your DWAN computer.

2. In the DRMIS production environment, run the following transaction with the specified parameters:

    * **IE 36 - Display Vehicles**
        * _Class Type_: `002`
        * _Class_: `VEH_EQUIP`
        * _Vehicle Type_: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`
        * Once the transaction finishes running (may take several minutes), select all of the records, and click _Settings_, followed by _Show/Hide Classification_

3. Export the results to Excel, and save the file to your USB drive as `ie36.xlsx`.

4. In the DRMIS production environment, run the following transaction with the specified parameters:

    * **ZEIW29 - List Edit Display Notification (UDF)**
        * _Notification status_: `Outstanding`, `Postponed` and `In process`
        * _Planning plant_: `0001`
        * Once the transaction finishes running, add the _Equipment_ column
 
5. Export the results to Excel, and save the file to your USB drive as `zeiw29.xlsx`.

6. Using DRMIS Business Explorer Analyzer, run the following transaction with the specified parameters:
 
    * **[ZPM_0EQUIPMENT_7028_Q01] VOR Tactical - MPO Disposition**
        * _Force Element Hierarchy_: `[3663] Minister of National Defence` and `[REST_H] Not Assigned Force Element`
        * _Equip. Object Type_: `EV0309`, `EV0B54`, `EV0B68`, `EV0B80`, `EV0B82`, `EV0B94`, `EV0B97`, `EV0J06`, `EV0J07`, `EV0J08`, `EV0J31`, `EV0J35`, `EV0J36`, `EV0J37`, `EV0J38`, `EV0J44`, `EV0J46`, `EV0J81`, `EV0J82` and `EV0J83`
        * _Master Equip Index_: `X`
        * Once the transaction finishes running, right click on any table heading (e.g. _Equipment Number_), and click _Query Properties_:
            * In the _Navigational State_ tab:
                * In the _Columns_ field, right click on _Key Figures_ and click _Select Filter Value_. Move all but `Qty Held` from _Chosen Selections_ to _Displayed Key Figures_ (select each and click the left arrow icon)
                * In the _Rows_ field, move all but `Equip. Object Type` to _Free Characteristics_ (select each and click the right arrow icon)
                * In the _Free Characteristics_ field, move `Equipment Number`, `Maintenance plant` and `User & Info Statuses` to _Rows_ (select each and click the left arrow icon)
            * In the _Display Options_ tab:
                * Uncheck _Suppress Repeated Key Values_

7. Select all of the table headings and rows, copy and paste into a new Excel file, and save it to your USB drive as `vor_tactical_mpo_disposition.xlsx`.

8. Disconnect your USB drive from your DWAN computer and connect it to your standalone computer (e.g. Dell XPS 13).

9. On your standalone computer, create the following directories (folders):
    * `/home/{username}/Desktop/dglepm-availability-report`
    * `/home/{username}/Desktop/dglepm-availability-report/infiles`
    * `/home/{username}/Desktop/dglepm-availability-report/outfiles`
  
10. Clone the repository from GitHub to your standalone computer. To do so, copy the URL to the `.git` file by clicking the _Code_ button, followed by the _Clipboard_ icon. Open Terminal (or Git Bash), type `cd PycharmProjects` and press the _Enter_ key to navigate to the PycharmProjects directory (`/home/{username}/PycharmProjects/`). Type `git clone ` (include a trailing space), paste the copied URL and press the _Enter_ key to clone the repository. You should now have a local copy of the repository.

11. Copy and paste the 3 files from your USB drive to the following directory: `/home/{username}/Desktop/dglepm-availability-report/infiles/`.

12. To run the script using PyCharm, open PyCharm and select the `dglepm-availability-report` project. In `dglepmAvailabilityReport.py`, change the `user` variable (line 8) to your standalone computer username (e.g. `matthew`). Click the green _Run_ button in the top right-hand corner.

13. To run the script using Terminal, in Terminal's default directory (`/home/{username}`), type `python3 ./PyCharmProjects/dglepm-availability-report/dglepmAvailabilityReport.py` and press the _Enter_ key.

14. Wait until the program finishes executing (approximately 10 seconds), and navigate to the following directory: `/home/{user}/Desktop/dglepm-availability-report/outfiles/`.

15. Copy and paste the report file to your USB drive.

## Useful Links

1. **DND Departmental Results Report**: https://www.canada.ca/en/department-national-defence/corporate/reports-publications/departmental-results-report.html
1. **DND 2018-19 Departmental Results Report (most recent)**: https://www.canada.ca/content/dam/dnd-mdn/documents/departmental-results-report/2018-19-drr/english/DRR-2018-19_DND_English.pdf
2. **GC Infobase**: https://www.tbs-sct.gc.ca/ems-sgd/edb-bdd/index-eng.html#start
3. **GC Infobase Equipment Availability Single Indicator Details**: https://www.tbs-sct.gc.ca/ems-sgd/edb-bdd/index-eng.html#indicator/PROGRAM-dr18-5936
