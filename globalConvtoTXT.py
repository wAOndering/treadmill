import os

path='C:/Users/Windows/Desktop/SyngapKO 9-19-19 shock/test/'
files=os.listdir(path)

for i,j in enumerate(files):
	print(i, path+j)
	os.rename(path+j, path+j+'30d1.csv')



