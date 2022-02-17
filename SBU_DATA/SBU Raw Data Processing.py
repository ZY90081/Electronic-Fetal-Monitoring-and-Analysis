# SBU FHR Dataset: 2018 Jan - 2020 Dec
# This code is for processing SBU FHR RAW DATA
# Liu Yang
# V1: Jan 14, 2022
# V2: Feb 17, 2022

import glob
import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt
import datetime
import seaborn as sns


'''
Read Clinical Information
'''
#birthtimes = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/birth_times.csv', index_col='PERSON_ID')
#mflink = pd.read_csv('/Users/liuyang/Desktop/Version2 IssueLabel/mother_child_link.csv',index_col='CHILD_PERSON_ID')
#mflink['birth_times'] = birthtimes

FileTable = pd.read_csv('D:/FHR SBU DATA/mother_baby_link_2018_JAN_through_2020_DEC.csv',index_col='INFANT_PERSON_ID')

nicu = pd.read_csv('D:/FHR SBU DATA/infantIDs with nicu.txt',header=None).values.reshape(-1)
delayed = pd.read_csv('D:/FHR SBU DATA/infantIDs with delayed transition.txt',header=None).values.reshape(-1)
enceph = pd.read_csv('D:/FHR SBU DATA/infantIDs with encephalopathy.txt',header=None).values.reshape(-1)
hypoxia = pd.read_csv('D:/FHR SBU DATA/infantIDs with hypoxia.txt',header=None).values.reshape(-1)
perdep = pd.read_csv('D:/FHR SBU DATA/infantIDs with perinatal depression.txt',header=None).values.reshape(-1)
respiratory = pd.read_csv('D:/FHR SBU DATA/infantIDs with respiratory distress.txt',header=None).values.reshape(-1)
ischemia = pd.read_csv('D:/FHR SBU DATA/infantIDs with ischemia.txt',header=None).values.reshape(-1)
FileTable.loc[nicu, 'nicu'] = 1
FileTable.loc[delayed, 'delayed'] = 1
FileTable.loc[enceph, 'enceph'] = 1
FileTable.loc[hypoxia, 'hypoxia'] = 1
FileTable.loc[perdep, 'perdep'] = 1
FileTable.loc[respiratory, 'respiratory'] = 1
FileTable.loc[ischemia, 'ischemia'] = 1
FileTable = FileTable.replace(np.nan, 0)

INFANT_ID = FileTable.index
FileTable.insert(1, 'INFANT_PERSON_ID', INFANT_ID)
FileTable.index = range(len(FileTable.index))

'''
Read the last files
Check the length of the last recording file
'''
os.chdir('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals')  # change directory
#filenames = pd.Series([i for i in glob.glob('*')])
l = 60 * 60   # length in seconds
FHR = pd.DataFrame(columns = range(1,l*4+1))
FHR2nd = pd.DataFrame(columns = range(1,l*4+1))
MHR = pd.DataFrame(columns = range(1,l*4+1))
UA = pd.DataFrame(columns = range(1,l*4+1))
for i in range(len(FileTable)):
    print('Doing No. '+str(i))
    motherid = str(FileTable.at[i,'MOTHER_PERSON_ID'])
    childid = str(FileTable.at[i,'INFANT_PERSON_ID'])
    birthtime = str(FileTable.at[i,'BIRTH_DT_TM'])
    dateformat = datetime.datetime.strptime(birthtime, "%m/%d/%Y %H:%M")
    #print(dateformat.year)
    #print(dateformat.month)
    #print(dateformat.day)
    #print(dateformat.hour)
    #print(dateformat.minute)

    # open the folder of specific mother ID
    if not os.path.isdir('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals/'+motherid):
        FileTable.loc[i, 'Missing'] = 1
        # store data
        addon = np.empty((1, l * 4))
        addon[:] = np.NaN
        FHR.loc[i] = np.append(addon,[])
        FHR2nd.loc[i] = np.append(addon,[])
        MHR.loc[i] = np.append(addon,[])
        UA.loc[i] = np.append(addon,[])
        continue
    else:
        os.chdir('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals/'+motherid)  # change directory
    filenames = pd.Series([i for i in glob.glob('*')])
    if filenames.empty:
        FileTable.loc[i, 'Missing'] = 2
        # store data
        addon = np.empty((1, l * 4))
        addon[:] = np.NaN
        FHR.loc[i] = np.append(addon,[])
        FHR2nd.loc[i] = np.append(addon,[])
        MHR.loc[i] = np.append(addon,[])
        UA.loc[i] = np.append(addon,[])
        continue

    dateseq1 = str(dateformat.month).zfill(2) + '_' + str(dateformat.day).zfill(2) + '_' + str(dateformat.year)
    dateseq2 = str(dateformat.month).zfill(2) + '_' + str(dateformat.day-1).zfill(2) + '_' + str(dateformat.year)
    subfilenames = filenames[(filenames.str.contains(dateseq1, regex=False)) | (filenames.str.contains(dateseq2, regex=False))]
    if subfilenames.empty:
        FileTable.loc[i, 'Missing'] = 3
        # store data
        addon = np.empty((1, l * 4))
        addon[:] = np.NaN
        FHR.loc[i] = np.append(addon,[])
        FHR2nd.loc[i] = np.append(addon,[])
        MHR.loc[i] = np.append(addon,[])
        UA.loc[i] = np.append(addon,[])
        continue

    lastfilename = subfilenames.iat[-1]  # get the last file recorded
    #subfilenames = filenames[(filenames.str.contains(str(dateformat.year), regex=False)) & (filenames.str.contains(str(dateformat.month), regex=False)) & (filenames.str.contains(str(dateformat.month), regex=False)) & (filenames.str.contains(str(dateformat.day), regex=False))] # picking up files of certain baby
    #lastfilename = subfilenames.iat[-1]  # get the last file recorded
    data = pd.read_csv('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals/'+motherid +'/'+lastfilename)

    # check if birthtime exists
    if (dateformat.hour == 0) and (dateformat.minute == 00):
        FileTable.loc[i, 'ISbirthtime'] = 0
    else:
        FileTable.loc[i, 'ISbirthtime'] = 1

    # If the birthtime does not exist:
    if FileTable.loc[i, 'ISbirthtime'] == 0:
        f1 = data[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr of child no.1
        f2 = data[['C2 HR0', 'C2 HR1', 'C2 HR2', 'C2 HR3']]  # for fhr of child no.2
        u = data[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
        combine = pd.concat([f1, f2, u], axis=1, join='inner')
        combine['sum'] = combine.sum(axis=1)
        pointer = combine.index[-1]  # get the index of the last row
        while (combine['sum'].loc[pointer] == 0):
            pointer -= 1
            if pointer < combine.index[0]:
                break

        if pointer < combine.index[0]:
            FileTable.loc[i, 'Missing'] = 4
            # store data
            addon = np.empty((1, l * 4))
            addon[:] = np.NaN
            FHR.loc[i] = np.append(addon,[])
            FHR2nd.loc[i] = np.append(addon,[])
            MHR.loc[i] = np.append(addon,[])
            UA.loc[i] = np.append(addon,[])
            continue

        FileTable.loc[i, 'IndexBirthTime'] = pointer  # This is the index of estimated birth time
        data['Acquired Time'] = pd.to_datetime(data['Acquired Time'], format='%Y-%m-%d::%H:%M:%S.%f')
        est_year = data['Acquired Time'].dt.year[pointer]
        est_month = data['Acquired Time'].dt.month[pointer]
        est_day = data['Acquired Time'].dt.day[pointer]
        est_hour = data['Acquired Time'].dt.hour[pointer]
        est_minute = data['Acquired Time'].dt.minute[pointer]
        est_second = data['Acquired Time'].dt.second[pointer]
        FileTable.loc[i, 'EstimatedEndTime'] = str(est_month)+'/'+str(est_day)+'/'+str(est_year)+' '+str(est_hour)+':'+str(est_minute)+':'+str(est_second)

        # extract time series data
        FileTable.loc[i, 'TotalTime(mins)_LastFile'] = int(pointer*4)/4/60   # mins
        if pointer+1 < l:
            lasthourdata = data.loc[:pointer]
        else:
            lasthourdata = data.loc[pointer-l+1:pointer]
        f1 = lasthourdata[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr of child no.1
        f2 = lasthourdata[['C2 HR0', 'C2 HR1', 'C2 HR2', 'C2 HR3']]  # for fhr of child no.2
        m = lasthourdata[['MHR 0', 'MHR 1', 'MHR 2', 'MHR 3']]  # for mhr
        u = lasthourdata[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
        f1 = f1.values.reshape(-1)
        f2 = f2.values.reshape(-1)
        m = m.values.reshape(-1)
        u = u.values.reshape(-1)
        # check the length of signals
        FileTable.loc[i, 'TimeLength(mins)'] = int(f1.shape[0]) / 4 / 60  # mins
        # store data
        addon = np.empty((1, l * 4 - f1.shape[0]))
        addon[:] = np.NaN
        FHR.loc[i] = np.append(addon, f1)
        FHR2nd.loc[i] = np.append(addon, f2)
        MHR.loc[i] = np.append(addon, m)
        UA.loc[i] = np.append(addon, u)


    # If the birthtime exists:
    if FileTable.loc[i, 'ISbirthtime'] == 1:
        data['Acquired Time'] = pd.to_datetime(data['Acquired Time'], format='%Y-%m-%d::%H:%M:%S.%f')
        datayearboo = data['Acquired Time'].dt.year == dateformat.year
        datamonthboo = data['Acquired Time'].dt.month == dateformat.month
        datadayboo = data['Acquired Time'].dt.day == dateformat.day
        datahourboo = data['Acquired Time'].dt.hour == dateformat.hour
        dataminuteboo = data['Acquired Time'].dt.minute == dateformat.minute
        subdata = data[datayearboo & datamonthboo & datadayboo & datahourboo & dataminuteboo]
        if subdata.empty:   # missing data at birth
            FileTable.loc[i, 'ISbirthtime'] = -1
            # if so, we estimate the birth time.
            f1 = data[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr of child no.1
            f2 = data[['C2 HR0', 'C2 HR1', 'C2 HR2', 'C2 HR3']]  # for fhr of child no.2
            u = data[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
            combine = pd.concat([f1, f2, u], axis=1, join='inner')
            combine['sum'] = combine.sum(axis=1)
            pointer = combine.index[-1]  # get the index of the last row
            while (combine['sum'].loc[pointer] == 0):
                pointer -= 1
                if pointer < combine.index[0]:
                    break

            if pointer < combine.index[0]:
                FileTable.loc[i, 'Missing'] = 4
                # store data
                addon = np.empty((1, l * 4))
                addon[:] = np.NaN
                FHR.loc[i] = np.append(addon,[])
                FHR2nd.loc[i] = np.append(addon,[])
                MHR.loc[i] = np.append(addon,[])
                UA.loc[i] = np.append(addon,[])
                continue

            FileTable.loc[i, 'IndexBirthTime'] = pointer  # This is the index of estimated birth time
            data['Acquired Time'] = pd.to_datetime(data['Acquired Time'], format='%Y-%m-%d::%H:%M:%S.%f')
            est_year = data['Acquired Time'].dt.year[pointer]
            est_month = data['Acquired Time'].dt.month[pointer]
            est_day = data['Acquired Time'].dt.day[pointer]
            est_hour = data['Acquired Time'].dt.hour[pointer]
            est_minute = data['Acquired Time'].dt.minute[pointer]
            est_second = data['Acquired Time'].dt.second[pointer]
            FileTable.loc[i, 'EstimatedEndTime'] = str(est_month) + '/' + str(est_day) + '/' + str(
                est_year) + ' ' + str(est_hour) + ':' + str(est_minute) + ':' + str(est_second)
            # extract time series data
            FileTable.loc[i, 'TotalTime(mins)_LastFile'] = int(pointer * 4) / 4 / 60  # mins
            if pointer + 1 < l:
                lasthourdata = data.loc[:pointer]
            else:
                lasthourdata = data.loc[pointer - l + 1:pointer]
            f1 = lasthourdata[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr of child no.1
            f2 = lasthourdata[['C2 HR0', 'C2 HR1', 'C2 HR2', 'C2 HR3']]  # for fhr of child no.2
            m = lasthourdata[['MHR 0', 'MHR 1', 'MHR 2', 'MHR 3']]  # for mhr
            u = lasthourdata[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
            f1 = f1.values.reshape(-1)
            f2 = f2.values.reshape(-1)
            m = m.values.reshape(-1)
            u = u.values.reshape(-1)
            # check the length of signals
            FileTable.loc[i, 'TimeLength(mins)'] = int(f1.shape[0]) / 4 / 60  # mins
            # store data
            addon = np.empty((1, l * 4 - f1.shape[0]))
            addon[:] = np.NaN
            FHR.loc[i] = np.append(addon, f1)
            FHR2nd.loc[i] = np.append(addon, f2)
            MHR.loc[i] = np.append(addon, m)
            UA.loc[i] = np.append(addon, u)
            continue

        f1 = data[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr of child no.1
        f2 = data[['C2 HR0', 'C2 HR1', 'C2 HR2', 'C2 HR3']]  # for fhr of child no.2
        u = data[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
        combine = pd.concat([f1, f2, u], axis=1, join='inner')
        combine['sum'] = combine.sum(axis=1)
        pointer = subdata.index[-1]  # get the index of the registered birth time
        while (combine['sum'].loc[pointer] == 0):
            pointer -= 1
            if pointer < combine.index[0]:
                break

        if pointer < combine.index[0]:
            FileTable.loc[i, 'Missing'] = 4
            # store data
            addon = np.empty((1, l * 4))
            addon[:] = np.NaN
            FHR.loc[i] = np.append(addon,[])
            FHR2nd.loc[i] = np.append(addon,[])
            MHR.loc[i] = np.append(addon,[])
            UA.loc[i] = np.append(addon,[])
            continue

        FileTable.loc[i, 'IndexBirthTime'] = pointer  # This is the index of estimated birth time
        data['Acquired Time'] = pd.to_datetime(data['Acquired Time'], format='%Y-%m-%d::%H:%M:%S.%f')
        est_year = data['Acquired Time'].dt.year[pointer]
        est_month = data['Acquired Time'].dt.month[pointer]
        est_day = data['Acquired Time'].dt.day[pointer]
        est_hour = data['Acquired Time'].dt.hour[pointer]
        est_minute = data['Acquired Time'].dt.minute[pointer]
        est_second = data['Acquired Time'].dt.second[pointer]
        FileTable.loc[i, 'EstimatedEndTime'] = str(est_month) + '/' + str(est_day) + '/' + str(
            est_year) + ' ' + str(est_hour) + ':' + str(est_minute) + ':' + str(est_second)
        # extract time series data
        FileTable.loc[i, 'TotalTime(mins)_LastFile'] = int(pointer * 4) / 4 / 60  # mins
        if pointer + 1 < l:
            lasthourdata = data.loc[:pointer]
        else:
            lasthourdata = data.loc[pointer - l + 1:pointer]
        f1 = lasthourdata[['C1 HR0', 'C1 HR1', 'C1 HR2', 'C1 HR3']]  # for fhr of child no.1
        f2 = lasthourdata[['C2 HR0', 'C2 HR1', 'C2 HR2', 'C2 HR3']]  # for fhr of child no.2
        m = lasthourdata[['MHR 0', 'MHR 1', 'MHR 2', 'MHR 3']]  # for mhr
        u = lasthourdata[['TOCO 0', 'TOCO 1', 'TOCO 2', 'TOCO 3']]  # for UA
        f1 = f1.values.reshape(-1)
        f2 = f2.values.reshape(-1)
        m = m.values.reshape(-1)
        u = u.values.reshape(-1)
        # check the length of signals
        FileTable.loc[i, 'TimeLength(mins)'] = int(f1.shape[0]) / 4 / 60  # mins
        # store data
        addon = np.empty((1, l * 4 - f1.shape[0]))
        addon[:] = np.NaN
        FHR.loc[i] = np.append(addon, f1)
        FHR2nd.loc[i] = np.append(addon, f2)
        MHR.loc[i] = np.append(addon, m)
        UA.loc[i] = np.append(addon, u)

# save last-hour data
os.chdir('D:/FHR SBU DATA/')
FileTable.to_csv('FileTable.csv')
FHR.to_csv('FHR.csv')
FHR2nd.to_csv('FHR2nd.csv')
MHR.to_csv('MHR.csv')
UA.to_csv('UA.csv')
