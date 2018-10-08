TASK LOG
=============

Version 1.4

## 2018-06-04

> Changes from MAK (found in `Text/SEG Shiny App Notes MAK.docx`)

#### Instructions Tab [text]

> add this test to the instructions tab:

Upload your data in a comma separated variables (CSV) file by clicking on the “Browse” button in the left sidebar panel. Please refer to the image below.  Your CSV file should contain only two columns.  The blood glucose monitor (BGM) readings should be in the leftmost column under the heading “BGM”.  These are the meter readings or point-of-care readings.  The reference values should be in the next column under the label “REF”.  Reference values might come from simultaneously obtained plasma specimens run on a laboratory analyzer such as the YSI Life Sciences 2300 Stat Plus Glucose Lactate Analyzer. If you have any questions about how your CSV data file should look before uploading it, please download the sample data set we have provided.

> - [x] complete 2018-06-04


#### The Summary Tables tab [text]

This contains the number of BGM values that were 1) less than the REF values, 2) equal to the REF values, and 3) greater than the REF values. Note that REF values < 21 mg/dL or >600 mg/dL will not be plotted on the SEG heatmap. This tab also stratifies the values across eight clinical risk levels.

> - [x] complete 2018-06-04

#### Heatmap tab

After uploading a .csv file, a static heatmap will be generated from the BGM and REF values. You may customize your static heatmap parameters in the left sidebar panel and download the heatmap to your computer (as either a .png or .pdf). See the example provided below:

> - [x] complete 2018-06-04

#### Summary Tables Tab [text]

Do not display the header.  It will confuse users.

> - [ ]

Express Bias, MARD, CV, Lower Limit, and Upper Limit as percentages.  E.g. Bias = -1.0%

Lower Limit should be “Lower 95% Limit of Agreement”

Upper Limit should be “Upper 95% Limit of Agreement”

If possible Risk Categories should be color coded as in the Excel file.
Note: Dr. Klonoff is going to want us to additionally present a table with some of the categories merged.  I will discuss this with you.

#### BGM Surveillance Study Criteria Tab [text]

Can we move this table to the Summary Tables Tab and then eliminate this tab?

This also requires a calculation to determine whether the BGM met Surveillance Study accuracy criteria.  I can show you this calculation.

#### MARD

Delete this tab

***


## 2018-05-25

- Version 1.1 needs better descriptions of the statistics on the instructions tab, and possibly on the other tabs...
- Version 1.1 heatmap should be converted to function so the layers aren't built when file is uploaded.


## 2018-05-17

- Version 1.0 had the following error when trying to upload .csv files:

    Error: invalid argument type.

- Version 1.0 had the following error when trying to upload to web:

    Preparing to deploy application...DONE
    Uploading bundle for application: 345205...DONE
    Deploying bundle: 1380411 for application: 345205 ...
    Waiting for task: 526474079
      building: Parsing manifest
      building: Building image: 1393341
      building: Building package: crayon

    ############################ Begin Task Log ################################
    ############################# End Task Log #################################
    Error: Unhandled Exception: Child Task 526474080 failed: Error building
    image: Error building crayon (1.3.4). R version 3.5.0 currently unavailable
    Execution halted
