import math
import glob
import pandas as pd
import numpy as np
import datetime
import os
import csv

# Read Information Table
FileTable = pd.read_csv('D:/FHR SBU DATA/FileTable.csv', index_col=0)

# Read and extract last-hour data
l = 60*60   # length in seconds
FHR = pd.DataFrame(columns = range(1,l*4+1))
FHR2nd = pd.DataFrame(columns = range(1,l*4+1))
MHR = pd.DataFrame(columns = range(1,l*4+1))
UA = pd.DataFrame(columns = range(1,l*4+1))
#os.chdir('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals')
for i in range(len(FileTable)):
    print('Doing No. '+str(i))

    if not math.isnan(FileTable.loc[i,'Missing']):
        addon = np.empty((1, l * 4))
        addon[:] = np.NaN
        FHR.loc[i] = np.append(addon, [])
        FHR2nd.loc[i] = np.append(addon, [])
        MHR.loc[i] = np.append(addon, [])
        UA.loc[i] = np.append(addon, [])
        #FHR = np.append(addon, [])
        #FHR2nd = np.append(addon, [])
        #MHR = np.append(addon, [])
        #UA = np.append(addon, [])
        '''
        os.chdir('D:/FHR SBU DATA/')
        with open('FHR.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            writer.writerow(FHR)
        with open('FHR2nd.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            writer.writerow(FHR2nd)
        with open('MHR.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            writer.writerow(MHR)
        with open('UA.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            writer.writerow(UA)
        '''
        continue

    motherid = str(FileTable.at[i, 'MOTHER_PERSON_ID'])
    childid = str(FileTable.at[i, 'INFANT_PERSON_ID'])
    birthtime = str(FileTable.at[i, 'BIRTH_DT_TM'])
    dateformat = datetime.datetime.strptime(birthtime, "%m/%d/%Y %H:%M")
    os.chdir('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals/' + motherid)
    filenames = pd.Series([i for i in glob.glob('*')])
    dateseq1 = str(dateformat.month).zfill(2) + '_' + str(dateformat.day).zfill(2) + '_' + str(dateformat.year)
    dateseq2 = str(dateformat.month).zfill(2) + '_' + str(dateformat.day-1).zfill(2) + '_' + str(dateformat.year)
    subfilenames = filenames[(filenames.str.contains(dateseq1, regex=False)) | (filenames.str.contains(dateseq2, regex=False))]
    lastfilename = subfilenames.iat[-1]
    data = pd.read_csv('D:/FHR SBU DATA/FHR_Signals_by_motherID/Parsed_FHR_Signals/' + motherid + '/' + lastfilename)
    pointer = FileTable.loc[i, 'IndexBirthTime']
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
    # store data
    addon = np.empty((1, l * 4 - f1.shape[0]))
    addon[:] = np.NaN
    FHR.loc[i] = np.append(addon, f1)
    FHR2nd.loc[i] = np.append(addon, f2)
    MHR.loc[i] = np.append(addon, m)
    UA.loc[i] = np.append(addon, u)

    if len(FHR)>100:
        os.chdir('D:/FHR SBU DATA/')
        with open('FHR.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            for j in FHR.index:
                writer.writerow(FHR.loc[j])
        with open('FHR2nd.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            for j in FHR.index:
                writer.writerow(FHR2nd.loc[j])
        with open('MHR.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            for j in FHR.index:
                writer.writerow(MHR.loc[j])
        with open('UA.csv', 'a') as f:
            writer = csv.writer(f, delimiter=',', lineterminator='\n', )
            for j in FHR.index:
                writer.writerow(UA.loc[j])
        FHR = pd.DataFrame(columns=range(1, l * 4 + 1))
        FHR2nd = pd.DataFrame(columns=range(1, l * 4 + 1))
        MHR = pd.DataFrame(columns=range(1, l * 4 + 1))
        UA = pd.DataFrame(columns=range(1, l * 4 + 1))


