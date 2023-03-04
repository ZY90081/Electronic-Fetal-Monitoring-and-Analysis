# For selecting random samples of normal, abnormal and suspicious classes

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import math

def plotinUSAformat(MotherID, ChildID, FHR, FHR2, MHR, UA):
    cm = 1 / 2.54  # centimeters in inches
    fs = 4
    speed = 3   # (3cm / min)
    N = len(FHR)
    if N != 60*60*fs:
        print('The length of the signal is not 1 hour.')

    T = 6   # 6 segments
    for idx in range(1,T+1):
        t = [i / (fs * 60.) - 60 for i in range((idx-1)*10*60*fs, idx*10*60*fs)]   # 10 mins
        fhr = [FHR[i] for i in range((idx-1)*10*60*fs, idx*10*60*fs)]
        ua = [UA[i] for i in range((idx - 1) * 10 * 60 * fs, idx * 10 * 60 * fs)]
        n = len(t)
        #fig = plt.figure()
        fig, ax = plt.subplots(2, 1, figsize=(14 * speed * cm, 10 * cm))
        fig.suptitle('MotherID='+str(MotherID)+''+'ChildID='+str(ChildID), fontsize=12)
        ax[0].plot(t, fhr, color='red', label='FHR', lw=0.8)
        ax[0].fill_between(t, 110 * np.ones(n), 160 * np.ones(n), color='gray', alpha=0.2)
        ax[0].set_ylim([30, 240])
        ax[0].set_yticks([30, 60, 90, 120, 150, 180, 210, 240])
        ax[0].set_ylabel('FHR')
        plt.grid(axis='y', lw=0.1)
        plt.grid(False, axis='x')

        ax[1].set_ylim([0, 110])
        ax[1].plot(t, ua, lw=0.8, color='purple', label='UA')
        ax[1].set_xlabel('Time (mins) Before Birth')
        ax[1].set_ylabel('UA')
        plt.grid(axis='y', lw=0.1)
        plt.grid(False, axis='x')
        plt.savefig('MotherID'+str(MotherID)+''+'ChildID'+str(ChildID) + '(' + str(idx) + ')' + '.png')

    plt.show()

# Read Information Table
FileTable = pd.read_csv('E:/FHR SBU DATA/FileTable.csv', index_col=0)

# Filtered data satisfied conditions
FilteredData = FileTable[(FileTable['ISbirthtime'] == 1) & (FileTable['TimeLength(mins)'] == 60) & (FileTable['BabyOrder'] == 1) & (FileTable['DiffTime'] == 0) ]

# Normal
NormalData = FilteredData[(FilteredData['nicu'] == 0 ) & (FilteredData['delayed'] == 0 ) & (FilteredData['enceph'] == 0 ) & (FilteredData['hypoxia'] == 0 ) & (FilteredData['perdep'] == 0 ) & (FilteredData['respiratory'] == 0 ) & (FilteredData['ischemia'] == 0 )]

# Abnormal
AbnormalData = FilteredData[(FilteredData['nicu'] == 1 ) & ( (FilteredData['delayed'] == 1 ) | (FilteredData['enceph'] == 1 ) | (FilteredData['hypoxia'] == 1 ) | (FilteredData['ischemia'] == 1 ) ) ]

# Suspicious
SuspiciousData = FilteredData[(~FilteredData.MOTHER_PERSON_ID.isin(NormalData.MOTHER_PERSON_ID)) & (~FilteredData.INFANT_PERSON_ID.isin(NormalData.INFANT_PERSON_ID)) & (~FilteredData.MOTHER_ENCNTR_ID.isin(NormalData.MOTHER_ENCNTR_ID)) ]

SuspiciousData = SuspiciousData[(~SuspiciousData.MOTHER_PERSON_ID.isin(AbnormalData.MOTHER_PERSON_ID)) & (~SuspiciousData.INFANT_PERSON_ID.isin(AbnormalData.INFANT_PERSON_ID)) & (~SuspiciousData.MOTHER_ENCNTR_ID.isin(AbnormalData.MOTHER_ENCNTR_ID)) ]

M_normal = len(NormalData.index)
M_abnormal = len(AbnormalData.index)
M_suspicious = len(SuspiciousData.index)


# random selection
NormalSample = NormalData.sample(n = 14)
AbnormalSample = AbnormalData.sample(n = 13)
SuspiciousSample = SuspiciousData.sample(n = 13)

# Plotting
# Read Last-hour Data
FHR = pd.read_csv('E:/FHR SBU DATA/FHR.csv',  index_col=False,header=None)
#FHR2 = pd.read_csv('E:/FHR SBU DATA/FHR2nd.csv',  index_col=False,header=None)
#MHR = pd.read_csv('E:/FHR SBU DATA/MHR.csv',  index_col=False,header=None)
UA = pd.read_csv('E:/FHR SBU DATA/UA.csv',  index_col=False,header=None)

i = 0
while i<14:

    input_Mother = NormalSample['MOTHER_PERSON_ID'].values[i]
    input_Baby = NormalSample['INFANT_PERSON_ID'].values[i]

    temp = FileTable[(FileTable['MOTHER_PERSON_ID'] == int(input_Mother)) & (FileTable['INFANT_PERSON_ID'] == int(input_Baby))]
    if len(temp) == 1:
#        print('Which format you prefer (general or us): ')
#        input_format = input()
        input_index = temp.index
        fhr = FHR.loc[input_index].values.tolist()[0]
        #fhr2 = FHR2.loc[input_index].values.tolist()[0]
        #mhr = MHR.loc[input_index].values.tolist()[0]
        ua = UA.loc[input_index].values.tolist()[0]

#        if input_format == 'general':
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
        plt.savefig('NORMAL Mother ID_'+ str(input_Mother) +' '+ 'Baby ID_' + str(input_Baby) + '.png')
        plt.show()

    i = i + 1

        #print('Mother ID:'+ str(input_Mother))
        #print('Baby ID:' + str(input_Baby) )
        #print('Labels:')
        #print('NICU:'+ str(FileTable.at[input_index, 'nicu'])+' Delayed transition:'+str(FileTable.at[input_index, 'delayed'])+' Encephalopathy:'+str(FileTable.at[input_index, 'enceph']))
        #print('Hypoxia:'+str(FileTable.at[input_index, 'hypoxia'])+ ' Perinatal depression:'+str(FileTable.at[input_index, 'perdep']))
        #print('Respiratory distress:'+str(FileTable.at[input_index, 'respiratory'])+' Ischemia:'+str(FileTable.at[input_index, 'ischemia']))


#        if input_format == 'us':
#            plotinUSAformat(input_Mother, input_Baby, fhr, fhr2, mhr, ua)

#    else:
#        print('Wrong IDs...')


i = 0
while i<13:

    input_Mother = AbnormalSample['MOTHER_PERSON_ID'].values[i]
    input_Baby = AbnormalSample['INFANT_PERSON_ID'].values[i]

    temp = FileTable[(FileTable['MOTHER_PERSON_ID'] == int(input_Mother)) & (FileTable['INFANT_PERSON_ID'] == int(input_Baby))]
    if len(temp) == 1:
#        print('Which format you prefer (general or us): ')
#        input_format = input()
        input_index = temp.index
        fhr = FHR.loc[input_index].values.tolist()[0]
        #fhr2 = FHR2.loc[input_index].values.tolist()[0]
        #mhr = MHR.loc[input_index].values.tolist()[0]
        ua = UA.loc[input_index].values.tolist()[0]

#        if input_format == 'general':
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
        plt.savefig('ABNORMAL Mother ID_'+ str(input_Mother) +' '+ 'Baby ID_' + str(input_Baby) + '.png')
        plt.show()
    i = i + 1

i = 0
while i<13:


    input_Mother = SuspiciousSample['MOTHER_PERSON_ID'].values[i]
    input_Baby = SuspiciousSample['INFANT_PERSON_ID'].values[i]

    temp = FileTable[(FileTable['MOTHER_PERSON_ID'] == int(input_Mother)) & (FileTable['INFANT_PERSON_ID'] == int(input_Baby))]
    if len(temp) == 1:
#        print('Which format you prefer (general or us): ')
#        input_format = input()
        input_index = temp.index
        fhr = FHR.loc[input_index].values.tolist()[0]
        #fhr2 = FHR2.loc[input_index].values.tolist()[0]
        #mhr = MHR.loc[input_index].values.tolist()[0]
        ua = UA.loc[input_index].values.tolist()[0]

#        if input_format == 'general':
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
        plt.savefig('SUSPICIOUS Mother ID_'+ str(input_Mother) +' '+ 'Baby ID_' + str(input_Baby) + '.png')
        plt.show()

    i = i + 1
