import csv
import sys
from datetime import datetime
import os
import pandas as pd
# import seaborn as sns

user = 'matthew'

# def various functions
def dict_from_csv(file_path):
    with open(file_path, 'r') as f:
        reader = csv.reader(f, skipinitialspace=True, delimiter=',')
        next(reader)
        result = {}
        for row in reader:
            key = row[0]
            result[key] = row[1]
    return result


def list_from_csv(file_path):
    with open(file_path, 'r') as f:
        reader = csv.reader(f, skipinitialspace=True, delimiter=',')
        next(reader)
        list = []
        for row in reader:
            list.append(row[0])
    return list


def dict_str_to_float(dict):
    for k, v in dict.items():
        dict[k] = float(v)
    return dict


def dict_str_to_int(dict):
    for k, v in dict.items():
        dict[k] = int(v)
    return dict


# initialize variables with command line arguments or with defaults
if len(sys.argv) == 8:
    datestr1 = sys.argv[1]
    vor_tactical_mpo_disposition_filename = sys.argv[2]
    ie36_filename = sys.argv[3]
    zeiw29_filename = sys.argv[4]
    # vor_tactical_mpo_maintenance_status_filename = sys.argv[5]
    # mb25_filename = sys.argv[6]
    # mb25_filename = sys.argv[7]
elif len(sys.argv) == 1:
    datestr1 = datetime.now().strftime('%y%m%d')
    vor_tactical_mpo_disposition_filename = '/home/%s/Desktop/dglepm-availability-report/infiles/vor_tactical_mpo_disposition.xlsx' % user
    ie36_filename = '/home/%s/Desktop/dglepm-availability-report/infiles/ie36.xlsx' % user
    zeiw29_filename = '/home/%s/Desktop/dglepm-availability-report/infiles/zeiw29.xlsx' % user
    # vor_tactical_mpo_maintenance_status_filename = '/home/%s/Desktop/dglepm-availability-report/infiles/vor_tactical_mpo_maintenance_status.xlsx' % user
    # mb25_filename = '/home/%s/Desktop/dglepm-availability-report/infiles/mb25.xlsx' % user
    # mb52_filename = '/home/%s/Desktop/dglepm-availability-report/infiles/mb52.xlsx' % user
    print("Using default input filenames and today's date.")
else:
    raise Exception("Expected 7 arguments.")

# initialize second date string variable
datetime_object = datetime.strptime(datestr1, '%y%m%d')
datestr2 = datetime_object.strftime('%d %b %y')

# create output directory for input and output files
output_dir = '/home/matthew/Desktop/dglepm-availability-report/outfiles/%s' % datestr1
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# read input files
vor_tactical_mpo_disposition = pd.read_excel(vor_tactical_mpo_disposition_filename, sheet_name='Sheet1')
ie36 = pd.read_excel(ie36_filename, sheet_name='Sheet1')
zeiw29 = pd.read_excel(zeiw29_filename, sheet_name='Sheet1')
# vor_tactical_mpo_maintenance_status = pd.read_excel(vor_tactical_mpo_maintenance_status_filename, sheet_name='Sheet1')
# mb25 = pd.read_excel(mb25_filename, sheet_name='Sheet1')
# mb52 = pd.read_excel(mb52_filename, sheet_name='Sheet1')

# initialize list of disposal user status codes
disposal_user_status_code_list = list_from_csv('/home/matthew/PycharmProjects/dglepm-availability-report/misc/disposal_user_status_code_list.csv')

# initialize various dictionaries
weapon_system_id_dict = dict_from_csv('/home/matthew/PycharmProjects/dglepm-availability-report/misc/weapon_system_id_dict.csv')
np_drf_key_fleet_dict = dict_from_csv('/home/matthew/PycharmProjects/dglepm-availability-report/misc/np_drf_key_fleet_dict.csv')
platform_dict = dict_from_csv('/home/matthew/PycharmProjects/dglepm-availability-report/misc/platform_dict.csv')
maintenance_plant_dict = dict_from_csv('/home/matthew/PycharmProjects/dglepm-availability-report/misc/maintenance_plant_dict.csv')
availability_target_dict = dict_from_csv('/home/matthew/PycharmProjects/dglepm-availability-report/misc/availability_target_dict.csv')
availability_target_dict = dict_str_to_float(availability_target_dict)

# select relevant columns and rename them
vor_tactical_mpo_disposition = vor_tactical_mpo_disposition[['Equipment Number', 'Equip. Object Type', 'Maintenance plant', \
                                           'User & Info Statuses']]
vor_tactical_mpo_disposition.columns = ['equipment_number', 'equipment_object_type', 'maintenance_plant1', 'user_info_statuses']

ie36 = ie36[['Equipment', 'Description', 'Vehicle Type', 'Allocation Code']]
ie36.columns = ['equipment_number', 'description', 'equipment_object_type', 'allocation_code']

zeiw29 = zeiw29[['Equipment', 'Notification']]
zeiw29.columns = ['equipment_number', 'notification']

# vor_tactical_mpo_maintenance_status = vor_tactical_mpo_maintenance_status[['Highest-Level Equipm', 'PM Order']]
# vor_tactical_mpo_maintenance_status.columns = ['equipment_number', 'pm_order_number']

# mb25 = mb25[['Order', 'Material', 'Material Description']]
# mb25.columns = ['pm_order_number', 'material_number', 'material_description']

# mb52 = mb52[['External Long Material Number', 'Unrestructed']]
# mb52.columns = ['material_number', 'quantity']
# mb52['sum_of_quantity'] = mb52.groupby(['material_number'])['quantity'].transform(sum)
# mb52 = mb52[mb52['sum_of_quantity' == 0]]
# mb52 = mb52.drop_duplicates(subset='material_number').reset_index(drop=True)

# merge dataframes, removing duplicate rows due to multiple notifications being open against a single piece of eqpt
df1 = pd.merge(vor_tactical_mpo_disposition, ie36, left_on=['equipment_number', 'equipment_object_type'], \
               right_on=['equipment_number', 'equipment_object_type'], how='left')
df1 = pd.merge(df1, zeiw29.drop_duplicates(subset=['equipment_number']), left_on='equipment_number', \
               right_on='equipment_number', how='left')

# df2 = pd.merge(vor_tactical_mpo_maintenance_status, mb25, left_on='pm_order_number', right_on='pm_order_number', how='left')
# df2 = pd.merge(df2, mb52, left_on='material_number', right_on='material_number', how='left')
# df2['quantity'].replace('', np.nan, inplace=True)
# df2.dropna(subset=['quantity'], inplace=True)
# # TODO: are the next 2 lines of code necessary?
# df2 = df2.drop_duplicates(subset=['equipment_numnber', 'material_number'])
# df2 = df2.reset_index(drop=True)

# df3 = pd.merge(df1, df2, left_on='equipment_number', right_on='equipment_number', how='left')

# TODO: Temp variable assignment until zero-stock spares process refined
df3 = df1

# create 'disposal_status' column containing inferred disposal status
df3['service_status'] = 'In Service'
df3.loc[(df3['allocation_code'].str.contains('M')) | \
        (df3['description'].str.contains('HARD TARGET')) | \
        (df3['user_info_statuses'].str.contains('|'.join(disposal_user_status_code_list))), 'service_status'] = \
    'Disposal'

# map weapon system IDs, NP & DRF key fleets and platforms to equipment object types
df3['weapon_system_id'] = df3['equipment_object_type'].map(weapon_system_id_dict)
df3['np_drf_key_fleet'] = df3['equipment_object_type'].map(np_drf_key_fleet_dict)
df3['platform'] = df3['equipment_object_type'].map(platform_dict)
df3['maintenance_plant2'] = df3['maintenance_plant1'].apply(str).map(maintenance_plant_dict)

# create 'disposition' column containing plant if eqpt is in service and disposal status otherwise
df3['disposition'] = df3['maintenance_plant2']
df3.loc[(df3['notification'] > 0), 'disposition'] = '202 WD'
df3.loc[(df1['service_status'] == 'Disposal'), 'disposition'] = 'Disposal'

# group by weapon system ID, NP & DRF key fleet, platform and disposition, and calculate quantities
df4 = pd.DataFrame({'quantity': df3.groupby(['weapon_system_id', 'np_drf_key_fleet', 'platform', \
                                             'disposition']).size()}).reset_index()

# create pivot table and rename columns
table1 = pd.pivot_table(df4, values='quantity', index=['weapon_system_id', 'np_drf_key_fleet', 'platform'], \
                        columns=['disposition'], fill_value=0).reset_index()
table1.columns = ['weapon_system_id', 'np_drf_key_fleet', 'platform', '202_wd', 'adm_mat', 'ca', 'cjoc', \
                  'disposal', 'mpc', 'rcaf', 'rcn', 'vcds']

# create columns containing # in inventory, # in service, # available, # unavailable, % available and % unavailable
table1['inventory'] = table1.sum(axis=1)
table1['in_service'] = table1['inventory'] - table1['disposal']
table1['#_available'] = table1[['ca', 'cjoc', 'mpc', 'rcaf', 'rcn', 'vcds']].sum(axis=1)
table1['#_unavailable'] = table1[['202_wd', 'adm_mat']].sum(axis=1)
table1['%_available'] = (100 * table1['#_available'] / table1['in_service']).round(1)
table1['%_unavailable'] = (100 * table1['#_unavailable'] / table1['in_service']).round(1)

# map availability targets to platform names in '%_planned' column and create column containing # planned
table1['%_planned'] = table1['platform'].map(availability_target_dict)
table1['#_planned'] = (table1['%_planned'] * table1['in_service'] / 100).astype('int')

# rearrange table1 columns
table1 = table1[['weapon_system_id', 'np_drf_key_fleet', 'platform', 'inventory', 'disposal', 'in_service', \
                 '%_planned', '#_planned', 'ca', 'cjoc', 'mpc', 'rcaf', 'rcn', 'vcds', '%_available', \
                 '#_available', '202_wd', 'adm_mat', '%_unavailable', '#_unavailable']]

# create table2
table2 = table1.groupby(['np_drf_key_fleet']).sum().reset_index()
table2 = table2[['np_drf_key_fleet', '#_available', '#_planned', 'in_service', 'disposal']]

# rename table1 columns
table1.columns = ['Weapon System ID', 'NP & DRF Key Fleet', 'Platform', 'Inventory [1]', 'Disposal [2]', \
                 'In Service [3]', '% Planned [4]', '# Planned [5]', 'CA', 'CJOC', 'MPC', 'RCAF', 'RCN', \
                 'VCDS', '% Available [7]', '# Available [8]', '202 WD', 'ADM (Mat)', '% Unavailable [10]', \
                 '# Unavailable [11]']

# add rows containing column sum totals and average percentages
column_sums = table1.select_dtypes(include='int').sum(axis=0)
column_averages = table1.select_dtypes(include='float').mean(axis=0).round(1)
table1.loc['Sum'] = column_sums
table1.loc['Average'] = column_averages

# write dataframe to Excel file in output directory
filename2 = output_dir + '/%s-dglepm-availability-report.xlsx' % datestr1
writer = pd.ExcelWriter(filename2, engine='xlsxwriter')
table1.to_excel(writer, sheet_name='Sheet1', startrow=2, index=False)
df3.to_excel(writer, sheet_name='Sheet2', index=False)
table2.to_excel(writer, sheet_name='Sheet3', index=False)

# initialize generic variables
workbook = writer.book
worksheet1 = writer.sheets['Sheet1']
worksheet2 = writer.sheets['Sheet2']

# initialize formatting variables
integer_fmt = workbook.add_format({'text_wrap': True})
percentage_fmt = workbook.add_format({'text_wrap': True, 'num_format': '0.0"%"'})
bold_fmt = workbook.add_format({'bold': 1})
bold_align_center_fmt = workbook.add_format({'bold': 1, 'align': 'center'})
align_right_fmt = workbook.add_format({'align': 'right'})
bg_color_grey_fmt = workbook.add_format({'bg_color': '#C0C0C0'})
all_borders_fmt = workbook.add_format({'bottom': 1, 'top': 1, 'left': 1, 'right': 1})
top_border_fmt = workbook.add_format({'top': 1})
bottom_border_fmt = workbook.add_format({'bottom': 1})
left_border_fmt = workbook.add_format({'left': 1})
right_border_fmt = workbook.add_format({'right': 1})
underline_fmt = workbook.add_format({'underline': 1})
font_size_8_fmt = workbook.add_format({'font_size': 8})
underline_and_font_size_8_fmt = workbook.add_format({'underline': 1, 'font_size': 8})
italic_and_font_size_8_fmt = workbook.add_format({'italic': 1, 'font_size': 8})
red_fmt = workbook.add_format({'bg_color': '#FFC7CE', 'font_color': '#9C0006'})
index_fmt = workbook.add_format({'bold': 1, 'align': 'center', 'valign': 'top'})

# apply formatting to Sheet1
worksheet1.set_column('A:A', 24)
worksheet1.set_column('B:B', 40)
worksheet1.set_column('C:C', 16)
worksheet1.set_column('D:F', 16, integer_fmt)
worksheet1.set_column('G:G', 16, percentage_fmt)
worksheet1.set_column('H:H', 16, integer_fmt)
worksheet1.set_column('I:N', 12, integer_fmt)
worksheet1.set_column('O:O', 16, percentage_fmt)
worksheet1.set_column('P:P', 16, integer_fmt)
worksheet1.set_column('Q:R', 12, integer_fmt)
worksheet1.set_column('S:S', 16, percentage_fmt)
worksheet1.set_column('T:T', 16, integer_fmt)
# worksheet1.conditional_format('C5:V22', {'type': 'no_blanks', 'format': align_right_fmt})
# worksheet1.conditional_format('H3:M20', {'type': 'no_blanks', 'format': bg_color_grey_fmt})
# worksheet1.conditional_format('P3:R20', {'type': 'no_blanks', 'format': bg_color_grey_fmt})
# worksheet1.conditional_format('U3:U20', {'type': 'no_blanks', 'format': bg_color_grey_fmt})
# worksheet1.conditional_format('A21:V22', {'type': 'no_blanks', 'format': bg_color_grey_fmt})
worksheet1.conditional_format('A2:T24', {'type': 'no_blanks', 'format': all_borders_fmt})
worksheet1.conditional_format('I1:N1', {'type': 'no_blanks', 'format': all_borders_fmt})
worksheet1.conditional_format('Q1:R1', {'type': 'no_blanks', 'format': all_borders_fmt})
# worksheet1.conditional_format('A5:B20', {'type': 'no_blanks', 'format': bold_align_center_fmt})
worksheet1.write(0, 0, 'DGLEPM Availability Report', bold_fmt)
worksheet1.write(1, 0, 'As of %s' % datestr2)

# TODO: Not working
worksheet1.conditional_format('O3', {'type': 'cell', 'criteria': '<', 'value': '$G$3', 'format': red_fmt})
worksheet1.conditional_format('O4', {'type': 'cell', 'criteria': '<', 'value': '$G$4', 'format': red_fmt})
worksheet1.conditional_format('O5', {'type': 'cell', 'criteria': '<', 'value': '$G$5', 'format': red_fmt})
worksheet1.conditional_format('O6', {'type': 'cell', 'criteria': '<', 'value': '$G$6', 'format': red_fmt})
worksheet1.conditional_format('O7', {'type': 'cell', 'criteria': '<', 'value': '$G$7', 'format': red_fmt})
worksheet1.conditional_format('O8', {'type': 'cell', 'criteria': '<', 'value': '$G$8', 'format': red_fmt})
worksheet1.conditional_format('O9', {'type': 'cell', 'criteria': '<', 'value': '$G$9', 'format': red_fmt})
worksheet1.conditional_format('O10', {'type': 'cell', 'criteria': '<', 'value': '$G$10', 'format': red_fmt})
worksheet1.conditional_format('O11', {'type': 'cell', 'criteria': '<', 'value': '$G$11', 'format': red_fmt})
worksheet1.conditional_format('O12', {'type': 'cell', 'criteria': '<', 'value': '$G$12', 'format': red_fmt})
worksheet1.conditional_format('O13', {'type': 'cell', 'criteria': '<', 'value': '$G$13', 'format': red_fmt})
worksheet1.conditional_format('O14', {'type': 'cell', 'criteria': '<', 'value': '$G$14', 'format': red_fmt})
worksheet1.conditional_format('O15', {'type': 'cell', 'criteria': '<', 'value': '$G$15', 'format': red_fmt})
worksheet1.conditional_format('O16', {'type': 'cell', 'criteria': '<', 'value': '$G$16', 'format': red_fmt})
worksheet1.conditional_format('O17', {'type': 'cell', 'criteria': '<', 'value': '$G$17', 'format': red_fmt})
worksheet1.conditional_format('O18', {'type': 'cell', 'criteria': '<', 'value': '$G$18', 'format': red_fmt})
worksheet1.conditional_format('O19', {'type': 'cell', 'criteria': '<', 'value': '$G$19', 'format': red_fmt})
worksheet1.conditional_format('O20', {'type': 'cell', 'criteria': '<', 'value': '$G$20', 'format': red_fmt})
worksheet1.conditional_format('O21', {'type': 'cell', 'criteria': '<', 'value': '$G$21', 'format': red_fmt})
worksheet1.conditional_format('O22', {'type': 'cell', 'criteria': '<', 'value': '$G$22', 'format': red_fmt})
worksheet1.conditional_format('O24', {'type': 'cell', 'criteria': '<', 'value': '$G$24', 'format': red_fmt})
worksheet1.conditional_format('P3', {'type': 'cell', 'criteria': '<', 'value': '$H$3', 'format': red_fmt})
worksheet1.conditional_format('P4', {'type': 'cell', 'criteria': '<', 'value': '$H$4', 'format': red_fmt})
worksheet1.conditional_format('P5', {'type': 'cell', 'criteria': '<', 'value': '$H$5', 'format': red_fmt})
worksheet1.conditional_format('P6', {'type': 'cell', 'criteria': '<', 'value': '$H$6', 'format': red_fmt})
worksheet1.conditional_format('P7', {'type': 'cell', 'criteria': '<', 'value': '$H$7', 'format': red_fmt})
worksheet1.conditional_format('P8', {'type': 'cell', 'criteria': '<', 'value': '$H$8', 'format': red_fmt})
worksheet1.conditional_format('P9', {'type': 'cell', 'criteria': '<', 'value': '$H$9', 'format': red_fmt})
worksheet1.conditional_format('P10', {'type': 'cell', 'criteria': '<', 'value': '$H$10', 'format': red_fmt})
worksheet1.conditional_format('P11', {'type': 'cell', 'criteria': '<', 'value': '$H$11', 'format': red_fmt})
worksheet1.conditional_format('P12', {'type': 'cell', 'criteria': '<', 'value': '$H$12', 'format': red_fmt})
worksheet1.conditional_format('P13', {'type': 'cell', 'criteria': '<', 'value': '$H$13', 'format': red_fmt})
worksheet1.conditional_format('P14', {'type': 'cell', 'criteria': '<', 'value': '$H$14', 'format': red_fmt})
worksheet1.conditional_format('P15', {'type': 'cell', 'criteria': '<', 'value': '$H$15', 'format': red_fmt})
worksheet1.conditional_format('P16', {'type': 'cell', 'criteria': '<', 'value': '$H$16', 'format': red_fmt})
worksheet1.conditional_format('P17', {'type': 'cell', 'criteria': '<', 'value': '$H$17', 'format': red_fmt})
worksheet1.conditional_format('P18', {'type': 'cell', 'criteria': '<', 'value': '$H$18', 'format': red_fmt})
worksheet1.conditional_format('P19', {'type': 'cell', 'criteria': '<', 'value': '$H$19', 'format': red_fmt})
worksheet1.conditional_format('P20', {'type': 'cell', 'criteria': '<', 'value': '$H$20', 'format': red_fmt})
worksheet1.conditional_format('P21', {'type': 'cell', 'criteria': '<', 'value': '$H$21', 'format': red_fmt})
worksheet1.conditional_format('P22', {'type': 'cell', 'criteria': '<', 'value': '$H$22', 'format': red_fmt})
worksheet1.conditional_format('P23', {'type': 'cell', 'criteria': '<', 'value': '$H$23', 'format': red_fmt})
worksheet1.write(22, 2, 'Sum', bold_align_center_fmt)
worksheet1.write(23, 2, 'Average', bold_align_center_fmt)
worksheet1.write(23, 3, '-')
worksheet1.write(23, 4, '-')
worksheet1.write(23, 5, '-')
worksheet1.write(22, 6, '-')
worksheet1.write(23, 7, '-')
worksheet1.write(23, 8, '-')
worksheet1.write(23, 9, '-')
worksheet1.write(23, 10, '-')
worksheet1.write(23, 11, '-')
worksheet1.write(23, 12, '-')
worksheet1.write(23, 13, '-')
worksheet1.write(22, 14, '-')
worksheet1.write(23, 15, '-')
worksheet1.write(23, 16, '-')
worksheet1.write(23, 17, '-')
worksheet1.write(22, 18, '-')
worksheet1.write(23, 19, '-')
worksheet1.merge_range('I2:N2', 'Available [6]', bold_align_center_fmt)
worksheet1.merge_range('Q2:R2', 'Unavailable [9]', bold_align_center_fmt)
# worksheet1.conditional_format('A20', {'type': 'no_blanks', 'format': bold_align_center_fmt})
worksheet1.write(24, 0, 'Notes:', underline_and_font_size_8_fmt)
worksheet1.write(25, 0, '[1] Total eqpt holdings.', font_size_8_fmt)
worksheet1.write(26, 0, '[2] Eqpt that is awaiting disposal, or has been disposed of, but remains on charge. Includes \
eqpt where Description field contains “HARD TARGET”, User Status field contains “OBSO” (obsolete), “CBAL” \
(cannibalization), “MONU” (monument), “NOHT” (non-operational hard target) or “DLTD” (deleted), or Allocation Code \
field contains “M”.', font_size_8_fmt)
worksheet1.write(27, 0, '[3] Eqpt that is in service. Calculated as: Total − Disposal.', font_size_8_fmt)
worksheet1.write(28, 0, '[4] Target availability percentages designated by DGLEPM.', font_size_8_fmt)
worksheet1.write(29, 0, '[5] Calculated as: Planned Availability * In Service.', font_size_8_fmt)
worksheet1.write(30, 0, '[6] Eqpt that is held by a FG/FE L1, regardless of serviceability.', font_size_8_fmt)
worksheet1.write(31, 0, '[7] Calculated as: CA + RCAF + RCN + CJOC + VCDS + MPC.', font_size_8_fmt)
worksheet1.write(32, 0, '[8] Calculated as: 100 * Total Available / In Service.', font_size_8_fmt)
worksheet1.write(33, 0, '[9] Eqpt that is held by ADM (Mat), is undergoing 3rd/4th line maintenance at 202 WD or \
industry, or is held by DRDC for testing. Includes eqpt with outstanding or in process notifications under Planning \
Plant 0001 (202 WD).', font_size_8_fmt)
worksheet1.write(34, 0, '[10] Calculated as: ADM (Mat) + 202 WD + DRDC.', font_size_8_fmt)
worksheet1.write(35, 0, '[11] Calculated as: 100 * Total Unavailable / In Service.', font_size_8_fmt)
worksheet1.write(36, 0, '[12] Eqpt with incomplete DRMIS records (i.e. Plant field is blank). May include \
newly-fielded eqpt or eqpt undergoing EMO.', font_size_8_fmt)
worksheet1.write(37, 0, '[13] Calculated as: 100 * No FE Assigned / In Service.', font_size_8_fmt)
worksheet1.write(38, 0, 'Caveats:', underline_and_font_size_8_fmt)
worksheet1.write(39, 0, '1. Does not yet account for eqpt that is unavailable due to lack of furnished spares. Working \
on devising methodology.', font_size_8_fmt)
# worksheet1.conditional_format('A39:M39', {'type': 'no_blanks', 'format': top_border_fmt})
# worksheet1.conditional_format('A41:M41', {'type': 'no_blanks', 'format': bottom_border_fmt})
# worksheet1.conditional_format('A39:A41', {'type': 'no_blanks', 'format': left_border_fmt})
# worksheet1.conditional_format('K39:K41', {'type': 'no_blanks', 'format': right_border_fmt})
worksheet1.set_landscape()
worksheet1.set_paper(5)
worksheet1.fit_to_pages(1, 1)

# Save report
writer.save()