#what are the 

# dependencies
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os


# local functions
def merge(file1, file2):



def openTreadmillFile(myFile, descriptor):
		"""
		helper function to read the csv files acquired 
		"""
		data=pd.read_csv(myFile, header=None)
		data=data[0].str.split(pat=' ', expand=True)
		data=data.iloc[4:-1]		

		# conditional fork to format based on the type of file generated
		if ('[' in data.iloc[0,0])==True:
			# clean up the format to use 
			data[0] = data[0].map(lambda x: x.lstrip('[').rstrip(''))
			data[1] = data[1].map(lambda x: x.rstrip(']').rstrip(''))
			data=data[[0,1,2,4,6]]
			data=data.rename(columns={0:'date',1:'time',2:'dir',4:'distance',6:'speed'})
			data['time']=data['date']+[' ']+data['time']
			data['time']=pd.to_datetime(data['time'], format='%Y-%m-%d %H:%M:%S.%f')
			data['tera']='teraterm'
			data=data.drop('date', axis=1)

		else:
			# clean up the format to use 
			data=data[[0,2,4,6]]
			data=data.rename(columns={0:'time',2:'dir',4:'distance',6:'speed'})
			tmpDate=descriptor.loc[descriptor['Animal_id']==int(myFile.split(os.sep)[-2]), 'dateOnly'].item()
			data['date']=tmpDate
			data['time']=data['date']+[' ']+data['time']
			data['time']=pd.to_datetime(data['time'], format='%Y-%m-%d %H:%M:%S.%f')
			data['tera']='no'

		# get rid of the abnormal column and rows which are 
		data=data[pd.to_numeric(data.distance, errors='coerce').notnull()]
		data=data[pd.to_numeric(data.speed, errors='coerce').notnull()]
		data[['distance', 'speed']]=data[['distance', 'speed']].apply(pd.to_numeric)
		data['distStep']=np.concatenate(([0],np.diff(data.distance)))

		# calculate the cumulative motion by categories
		data.loc[data['dir']=='B','distanceCat']=np.cumsum(data.loc[data['dir']=='B','distStep'])
		data.loc[data['dir']=='F','distanceCat']=np.cumsum(data.loc[data['dir']=='F','distStep'])

		# reindex to the timeseries
		data.reset_index(inplace=True)
		data=data.drop('index', axis=1)
		data['timeStamp']=data['time']
		timeRef=data['time'][0]
		data['time']=data['time']-data['time'][0]

		return data, timeRef

def extractSummary(data, phase, name):
	"""
	extract summary of the data
	"""
	maxFdist=[data.loc[data['dir']=='F','distanceCat'].max()]
	maxBdist=[data.loc[data['dir']=='B','distanceCat'].max()]

	meanFspeed=[data.loc[data['dir']=='F','speed'].mean()]
	meanBspeed=[data.loc[data['dir']=='B','speed'].mean()]

	maxFspeed=[data.loc[data['dir']=='F','speed'].max()]
	maxBspeed=[data.loc[data['dir']=='B','speed'].max()]

	timeRec=[data.time.iloc[-1]]
	tera=np.unique(data.tera)

	summary=pd.DataFrame({'maxFdist': maxFdist,
						  'maxBdist': maxBdist,
						  'meanFspeed':meanFspeed,
						  'maxFspeed': maxFspeed,
						  'meanBspeed': meanBspeed,
						  'maxBspeed':maxBspeed,
						  'Animal_id':name,
						  'phase':phase,
						  'timeRec':timeRec,
						  'type':tera})
	return summary

def extractMaxima(data):
	"""
	helper function to extract the maxima and minima of the data
	"""

def plotDist(path, data, name, phase):
	"""
	helper function for ploting
	"""

	# # get the dimension of the figure 
	# 	fig = plt.gcf()
	# 	size = fig.get_size_inches()*fig.dpi # size in pixels
	# 	plt.figure(figsize=size)
	fig, (ax1, ax2) = plt.subplots(2)
	fig.set_size_inches(38.37,  3.75, forward=True)
	# fig.figure(figsize=size)

	ax1.plot('time','distanceCat', data=data[data['dir']=='F'], linestyle='none', marker='o', markersize=1, alpha=1, color='#3182BD', label='FW_dist')
	ax1.plot('time','distanceCat', data=data[data['dir']=='B'], linestyle='none', marker='o', markersize=1, alpha=1, color='#E6550D', label='BW_dist')


	ax2.plot(data.loc[data['dir']=='F','time'],data.loc[data['dir']=='F','speed'], linestyle='none', marker='o', markersize=1, alpha=1, color='#3182BD', label='FW_speed')
	ax2.plot(data.loc[data['dir']=='B','time'],-data.loc[data['dir']=='B','speed'], linestyle='none', marker='o', markersize=1, alpha=1, color='#E6550D', label='BW_dist')
	
	
	ref1=timeStart-timeRef
	ref2=timeStop-timeRef
	refTab=pd.DataFrame({'ref':[ref1, ref1, ref2, ref2],
						 'minMax':[min(-data.loc[data['dir']=='B','speed']), max(data.speed), min(-data.loc[data['dir']=='B','speed']), max(data.speed)]})
	ax2.plot(refTab.ref[0:2], refTab.minMax[0:2], color='red')
	ax2.plot(refTab.ref[2:4], refTab.minMax[2:4], color='red')

	fig.savefig(path+'output/'+str(name[0])+'_'+str(phase)+'.jpg', bbox_inches='tight', transparent=False)
	plt.close('all')


def recordingWindow(data):
	timeStart=pd.Timestamp(descriptor.loc[descriptor['Animal_id']==name[0],'Record_folder'].item())
	timeStop=timeStart+datetime.timedelta(seconds=6000)
	# data=data[(data['timeStamp']>=timeStart) & (data['timeStamp']<=timeStop)]
	return timeStart, timeStop


###############################################################
###############################################################

# local input to run function
direcT='C:/Users/Windows/Desktop/treadmilldata - Copy/'
folders=glob.glob(direcT+'/*/')
descriptor=pd.read_csv(glob.glob(direcT+'*.csv')[0])
descriptor=descriptor[['Animal_id', 'Animal_sex', 'Animal_geno', 'Record_folder']]

descriptor=descriptor.drop(3, axis=0)
descriptor[['dateOnly','timeOnly']]=descriptor['Record_folder'].str.split(pat='_', expand=True)
descriptor['Record_folder']=pd.to_datetime(descriptor['Record_folder'], format='%Y-%m-%d_%H-%M-%S')




###############################################################
###############################################################
###############################################################
###############################################################

# merge files for 7 and 8 which correspond to the same session
def easyOpen(file):
		data=pd.read_csv(file, header=None)
		data=data[0].str.split(pat=' ', expand=True)
		data=data.iloc[4:-1]
		if ('[' in data.iloc[0,0])==True:
			# clean up the format to use 
			data[0] = data[0].map(lambda x: x.lstrip('[').rstrip(''))
			data[1] = data[1].map(lambda x: x.rstrip(']').rstrip(''))
			data=data[[0,1,2,4,6]]
			data=data.rename(columns={0:'date',1:'time',2:'dir',4:'distance',6:'speed'})
			data['time']=data['date']+[' ']+data['time']
			data['time']=pd.to_datetime(data['time'], format='%Y-%m-%d %H:%M:%S.%f')
			data['tera']='teraterm'
			data=data.drop('date', axis=1)

		else:
			# clean up the format to use 
			data=data[[0,2,4,6]]
			data=data.rename(columns={0:'time',2:'dir',4:'distance',6:'speed'})
			tmpDate=descriptor.loc[descriptor['Animal_id']==558, 'dateOnly'].item()
			data['date']=tmpDate
			data['time']=data['date']+[' ']+data['time']
			data['time']=pd.to_datetime(data['time'], format='%Y-%m-%d %H:%M:%S.%f')
			data['tera']='no'

		# get rid of the abnormal column and rows which are 
		data=data[pd.to_numeric(data.distance, errors='coerce').notnull()]
		data=data[pd.to_numeric(data.speed, errors='coerce').notnull()]
		data[['distance', 'speed']]=data[['distance', 'speed']].apply(pd.to_numeric)
		data['distStep']=np.concatenate(([0],np.diff(data.distance)))

		return data

tobeMerged=glob.glob(direcT+'*\\8.csv', recursive=True)
for idFM, FM in enumerate(tobeMerged):
	subdir=os.path.dirname(tobeMerged[idFM])
	subdir=os.path.normpath(subdir)+'\\'
	file1=glob.glob(subdir+'7.csv')[0]
	file2=glob.glob(subdir+'8.csv')[0]
	file1=easyOpen(file1)
	file2=easyOpen(file2)

	file2.distance=file2.distance+file1.distance.iloc[-1]
	data=file1.append(file2)

	data.loc[data['dir']=='B','distanceCat']=np.cumsum(data.loc[data['dir']=='B','distStep'])
	data.loc[data['dir']=='F','distanceCat']=np.cumsum(data.loc[data['dir']=='F','distStep'])

	# reindex to the timeseries
	data.reset_index(inplace=True)
	data=data.drop('index', axis=1)
	data['timeStamp']=data['time']
	timeRef=data['time'][0]
	data['time']=data['time']-data['time'][0]


	def recordingWindow(data):
	timeStart=pd.Timestamp(descriptor.loc[descriptor['Animal_id']==name[0],'Record_folder'].item())
	timeStop=timeStart+datetime.timedelta(seconds=6000)
	# data=data[(data['timeStamp']>=timeStart) & (data['timeStamp']<=timeStop)]
	return timeStart, timeStop

	name=[558]
	phase=[7]

	plotDist(direcT, data, name, phase)

	pd.DataFrame.to_csv(data, subdir+'/new7.csv')

file1.head()
file1.tail()
file2.head()

###############################################################
###############################################################
###############################################################
###############################################################





mainSummary=[]
for i,l in enumerate(folders):
	print(i+1,'/',len(folders),' - ', l)
	csvFiles=glob.glob(l+'/*.csv')
	name=os.path.dirname(l)
	name=[int(os.path.basename(name))]

	for kk,ll in enumerate(csvFiles):
		print(kk+1,'/', len(csvFiles), ' - ', ll)
		phase=[int(os.path.basename(os.path.splitext(ll)[0]))]
		data=openTreadmillFile(ll)
		summary=extractSummary(data, phase, name)
		mainSummary.append(summary)

mainSummary=pd.concat(mainSummary)
mainSummary=pd.merge(mainSummary, descriptor)
pd.DataFrame.to_csv(mainSummary, direcT+'treadmillSummarye3.csv')


## PLOTING LOOP

for i,l in enumerate(folders):
	print(i+1,'/',len(folders),' - ', l)
	csvFiles=glob.glob(l+'/*.csv')
	name=os.path.dirname(l)
	name=[int(os.path.basename(name))]

	for kk,ll in enumerate(csvFiles):
		phase=[int(os.path.basename(os.path.splitext(ll)[0]))]
		print(phase)
		if phase ==[7]:
			data=openTreadmillFile(ll, descriptor)
			plotDist(direcT, data, name, phase)

## PLOTING LOOP for narrow recording window
for i,l in enumerate(folders):
	print(i+1,'/',len(folders),' - ', l)
	csvFiles=glob.glob(l+'/*.csv')
	name=os.path.dirname(l)
	name=[int(os.path.basename(name))]

	for kk,ll in enumerate(csvFiles):
		phase=[int(os.path.basename(os.path.splitext(ll)[0]))]
		print(phase)
		if (phase == [8]) or (phase ==[7]):
			data, timeRef=openTreadmillFile(ll, descriptor)
			timeStart, timeStop=recordingWindow(data)
			plotDist(direcT, data, name, phase)