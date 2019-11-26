import os

path='C:/Users/Windows/Desktop/SyngapKO 9-19-19 shock/SyngapKO 9-19-19 shock teraterm/'
files=os.listdir(path)

for i,j in enumerate(files):
	print(i, path+j)
	os.rename(path+j, path+os.path.splitext(j)[0]+'.csv')



os.rename(path+files[81], path+files[81]+'.txt')