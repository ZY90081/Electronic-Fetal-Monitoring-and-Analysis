import pandas as pd
import math
import matplotlib.pyplot as plt
import numpy as np
import datetime


# Read Information Table
FileTable = pd.read_csv('D:/FHR SBU DATA/FileTable.csv', index_col=0)


# 1: Statistics of Recordings
# check duplicated records
'''
Based on this result, we know that there is not duplicated motherID-infantID.
'''
Duplicated = FileTable.duplicated(subset=['MOTHER_PERSON_ID','INFANT_PERSON_ID'],keep=False)

Duplicated_baby = FileTable.loc[FileTable.duplicated(subset=['INFANT_PERSON_ID'],keep=False)]  # !!!!! need check

UniqueMotherIDs = FileTable['MOTHER_PERSON_ID'].unique()
NumofMom = len(UniqueMotherIDs)
UniqueInfantIDs = FileTable['INFANT_PERSON_ID'].unique()
NumofBaby = len(UniqueInfantIDs)

# mark the order of babies
Duplicated_mom = FileTable.loc[FileTable.duplicated(subset=['MOTHER_PERSON_ID'],keep=False)]
Duplicated_mom = Duplicated_mom.sort_values(by='MOTHER_PERSON_ID')
Duplicated_mom_index = Duplicated_mom.index
for i in range(len(Duplicated_mom)):
    temp_idx = Duplicated_mom_index[i]
    temp_momid = Duplicated_mom.loc[temp_idx,'MOTHER_PERSON_ID']
    # compare the birth times
    if i==0 or math.isnan(Duplicated_mom.loc[temp_idx, 'BabyOrder']):
        temp_select = Duplicated_mom[Duplicated_mom['MOTHER_PERSON_ID'] == temp_momid ]
        temp_select['BIRTH_DT_TM'] = pd.to_datetime(temp_select['BIRTH_DT_TM']).dt.strftime('%Y-%m-%d-%H-%M')
        temp_select = temp_select.sort_values(by='BIRTH_DT_TM')
        for j in range(len(temp_select)):
            Duplicated_mom.loc[temp_select.index[j], 'BabyOrder'] = j+1
            FileTable.loc[temp_select.index[j], 'BabyOrder'] = j+1

FileTable['BabyOrder'] = FileTable['BabyOrder'].fillna(1)

NumofBaby1st = len(FileTable[FileTable['BabyOrder'] == 1])
NumofBaby2nd = len(FileTable[FileTable['BabyOrder'] == 2])
NumofBaby3th = len(FileTable[FileTable['BabyOrder'] == 3])

x = [u'Third Babies', u'Second Babies', u'First Babies', u'Babies', u'Mothers']
y = [NumofBaby3th,NumofBaby2nd,NumofBaby1st,NumofBaby,NumofMom]
fig, ax = plt.subplots(figsize=(10,10))
width = 0.75 # the width of the bars
ind = np.arange(len(y))  # the x locations for the groups
ax.barh(ind, y, width, color="purple")
ax.set_yticks(ind+width/2)
ax.set_yticklabels(x, minor=False)
for i, v in enumerate(y):
    ax.text(v + 3, i + .25, str(v), color='purple', fontweight='bold')
#plt.title('')
plt.xlabel('Numbers')
#plt.ylabel('y')
plt.show()

# 2: Statistics of Birth Times
NumofRecordings = len(FileTable)
NumofBirthtime = len(FileTable[FileTable['ISbirthtime'] != 0])
NumofNOBirthtime = len(FileTable[FileTable['ISbirthtime'] == 0])
x = [u'No Birthtime', u'Have Birthtime', u'All Recordings']
y = [NumofNOBirthtime,NumofBirthtime,NumofRecordings]
fig, ax = plt.subplots(figsize=(10,10))
width = 0.75 # the width of the bars
ind = np.arange(len(y))  # the x locations for the groups
ax.barh(ind, y, width, color="purple")
ax.set_yticks(ind+width/2)
ax.set_yticklabels(x, minor=False)
for i, v in enumerate(y):
    ax.text(v + 3, i + .25, str(v), color='purple', fontweight='bold')
#plt.title('')
plt.xlabel('Numbers')
#plt.ylabel('y')
plt.show()

NumofData = len(FileTable[np.isnan(FileTable['Missing'])])
NumofMissingNo1 = len(FileTable[FileTable['Missing'] == 1])
NumofMissingNo2 = len(FileTable[FileTable['Missing'] == 2])
NumofMissingNo3 = len(FileTable[FileTable['Missing'] == 3])
NumofMissingNo4 = len(FileTable[FileTable['Missing'] == 4])
x = [u'All Zeros', u'No Matched Data File' ,u'No .csv Files', u'No folder of mother ID',u'Recordings with Data']
y = [NumofMissingNo4,NumofMissingNo3,NumofMissingNo2,NumofMissingNo1,NumofData]
fig, ax = plt.subplots(figsize=(15,10))
width = 0.75 # the width of the bars
ind = np.arange(len(y))  # the x locations for the groups
ax.barh(ind, y, width, color="purple")
ax.set_yticks(ind+width/2)
ax.set_yticklabels(x, minor=False)
for i, v in enumerate(y):
    ax.text(v + 3, i + .25, str(v), color='purple', fontweight='bold')
#plt.title('')
plt.xlabel('Numbers')
#plt.ylabel('y')
plt.show()

for i in range(len(FileTable)):
    if np.isnan(FileTable.loc[i,'Missing']):
        birthtime = str(FileTable.at[i, 'BIRTH_DT_TM'])
        dateformat_birth = datetime.datetime.strptime(birthtime, "%m/%d/%Y %H:%M")
        endtime = str(FileTable.at[i, 'EstimatedEndTime'])
        dateformat_end = datetime.datetime.strptime(endtime, "%m/%d/%Y %H:%M:%S")
        if dateformat_birth.year == dateformat_end.year:
            if dateformat_birth.month == dateformat_end.month:
                if dateformat_birth.day == dateformat_end.day:
                    diff = (dateformat_birth.hour - dateformat_end.hour) * 60 + (dateformat_birth.minute - dateformat_end.minute)
                    FileTable.loc[i,'DiffTime'] = diff
                elif dateformat_birth.day != dateformat_end.day:
                    diff = (dateformat_birth.day - dateformat_end.day)*24*60 + (dateformat_birth.hour - dateformat_end.hour) * 60 + (dateformat_birth.minute - dateformat_end.minute)
                    FileTable.loc[i, 'DiffTime'] = diff
            else:
                diff = 1 * 24 * 60 + (dateformat_birth.hour - dateformat_end.hour) * 60 + (
                                   dateformat_birth.minute - dateformat_end.minute)
                FileTable.loc[i, 'DiffTime'] = diff

FileTable.hist(column='DiffTime', grid=False ,bins=range(-2075,2025,50))
plt.show()
FileTable.hist(column='DiffTime', grid=False ,bins=range(-75,1025,50))
plt.show()

# 3: labels
Labels = FileTable[['nicu','delayed','enceph','hypoxia','perdep','respiratory','ischemia']]
Labels  = Labels .rename(columns={'nicu': 'N', 'delayed': 'D', 'enceph': 'E','hypoxia': 'H','perdep': 'P','respiratory': 'R','ischemia': 'I'})
LabelsSummary = pd.DataFrame()
for i in range(len(FileTable)):
    ColumnName = Labels.columns[np.where(Labels.loc[i] == 1)]
    NumofCol = len(ColumnName)
    colidx = '+'.join(ColumnName)
    if NumofCol == 0:
        colidx = 'None'

    if colidx not in LabelsSummary.columns:
        LabelsSummary.loc[0, colidx] = NumofCol
        LabelsSummary.loc[1,colidx] = 1
    else:
        LabelsSummary.loc[1,colidx] += 1

subColumn = LabelsSummary.loc[1,LabelsSummary.columns[np.where((LabelsSummary.loc[0] == 0) | (LabelsSummary.loc[0] == 1))]]
subColumn = subColumn.sort_values(axis = 0,ascending=False)
fig1= plt.figure(figsize=(10, 10), dpi=300)
#plots = sns.barplot(data=subColumn)
plots1 = subColumn.plot.bar()
plt.xticks(rotation=45)

subColumn = LabelsSummary.loc[1,LabelsSummary.columns[np.where(LabelsSummary.loc[0] == 2)]]
subColumn = subColumn.sort_values(axis = 0,ascending=False)
fig2 = plt.figure(figsize=(10, 10), dpi=300)
plots2 = subColumn.plot.bar()
plt.xticks(rotation=45)

subColumn = LabelsSummary.loc[1,LabelsSummary.columns[np.where(LabelsSummary.loc[0] == 3)]]
subColumn = subColumn.sort_values(axis = 0,ascending=False)
fig3 = plt.figure(figsize=(10, 10), dpi=300)
plots3 = subColumn.plot.bar()
plt.xticks(rotation=45)

subColumn = LabelsSummary.loc[1,LabelsSummary.columns[np.where(LabelsSummary.loc[0] == 4)]]
subColumn = subColumn.sort_values(axis = 0,ascending=False)
fig4 = plt.figure(figsize=(10, 10), dpi=300)
plots4 = subColumn.plot.bar()
plt.xticks(rotation=45)

subColumn = LabelsSummary.loc[1,LabelsSummary.columns[np.where((LabelsSummary.loc[0] == 5) | (LabelsSummary.loc[0] == 6) | (LabelsSummary.loc[0] == 7))]]
subColumn = subColumn.sort_values(axis = 0,ascending=False)
fig5 = plt.figure(figsize=(10, 10), dpi=300)
plots5 = subColumn.plot.bar()
plt.xticks(rotation=45)
plt.show()


# 4 Time Length
FileTable.hist(column='TotalTime(mins)_LastFile', grid=False ,bins=100)
plt.show()
FileTable.hist(column='TimeLength(mins)', grid=False ,bins=range(0,65,5))
plt.show()


# 5 Plot Signals:

# Read Information Table
FileTable = pd.read_csv('D:/FHR SBU DATA/FileTable.csv', index_col=0)
# Read Last-hour Data
FHR = pd.read_csv('D:/FHR SBU DATA/FHR.csv',  index_col=False,header=None)
FHR2 = pd.read_csv('D:/FHR SBU DATA/FHR2nd.csv',  index_col=False,header=None)
MHR = pd.read_csv('D:/FHR SBU DATA/MHR.csv',  index_col=False,header=None)
UA = pd.read_csv('D:/FHR SBU DATA/UA.csv',  index_col=False,header=None)

print('Please input the mother ID:')
input_Mother = input()
print('Please input the infant ID:')
input_Baby = input()

temp = FileTable[(FileTable['MOTHER_PERSON_ID'] == int(input_Mother)) & (FileTable['INFANT_PERSON_ID'] == int(input_Baby))]
if len(temp) == 1:
    print('Which format you prefer (general or us): ')
    input_format = input()
    input_index = temp.index
    fhr = FHR.loc[input_index].values.tolist()[0]
    fhr2 = FHR2.loc[input_index].values.tolist()[0]
    mhr = MHR.loc[input_index].values.tolist()[0]
    ua = UA.loc[input_index].values.tolist()[0]

    if input_format == 'general':
        N = len(fhr)
        t = [i / (4. * 60.) - 60 for i in range(0, N)]
        T = round(max(list(map(abs, t))))
        plt.figure(figsize=(T / 4, 3.5))
        plt.subplots_adjust(wspace=0, hspace=0)
        ax1 = plt.subplot(2, 1, 1)
        ax1.plot(t, fhr, color='blue', label='FHR', lw=0.5)
        ax1.set_title('Mother ID:'+ str(input_Mother) +' '+ 'Baby ID:' + str(input_Baby) )
        ax1.fill_between(t, 110 * np.ones(N), 160 * np.ones(N), color='gray', alpha=0.2)
        ax1.set_ylim([30, 240])
        ax1.set_yticks([30, 60, 90, 120, 150, 180, 210, 240])
        ax1.yaxis.grid(True, which='minor')
        plt.grid(axis='y', lw=0.1)
        plt.grid(False, axis='x')
        plt.legend()
        # -----------
        ax2 = plt.subplot(2, 1, 2, sharex=ax1)
        ax2.set_ylim([-5, 110])
        plt.plot(t, ua, lw=0.4, color='blue', label='UA')
        plt.grid(axis='y', lw=0.5)
        plt.grid(False, axis='x')
        plt.subplots_adjust(wspace=0, hspace=0)
        # plt.tight_layout()
        plt.legend()
        plt.show()

        print('Mother ID:'+ str(input_Mother))
        print('Baby ID:' + str(input_Baby) )
        print('Labels:')
        print('NICU:'+ str(FileTable.at[input_index, 'nicu'])+' Delayed transition:'+str(FileTable.at[input_index, 'delayed'])+' Encephalopathy:'+str(FileTable.at[input_index, 'enceph']))
        print('Hypoxia:'+str(FileTable.at[input_index, 'hypoxia'])+ ' Perinatal depression:'+str(FileTable.at[input_index, 'perdep']))
        print('Respiratory distress:'+str(FileTable.at[input_index, 'respiratory'])+' Ischemia:'+str(FileTable.at[input_index, 'ischemia']))

else:
    print('Wrong IDs...')

