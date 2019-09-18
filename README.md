# treadmill
contains code for arduino treadmill and data extraction  
**Need to update code functionality and documentation**

### to use the program
	1) copy all necessary file in the folder of interest with the .csv from teraterm
	* importfile.m
	* treadmill.m
	* Rplot.r
	* treadmillHab.m
	* an expinfo folder with genotype information see below



### notes for adding on analysis
* can use the actual (length()/height()) = number of data to perform some of the summary
* can use unique time bin (even with binning there is duplicate time):
	
	[valueWE,idxWE]=unique(WinTable.eventTime);
	WinTable(idxWE, :);
	
* analysis based on distance
* frequency distribution of instantaneous speed to and see large magnitude


### this is made to be able to read file and output data

Place the files:
* importfile.m
* treadmill.m
 in the folder (eg. C:/Desktop/) with csv of interest

to use the function type in Matlab Command Window:

treadmill('/home/rum/Dropbox (Scripps Research)/RumScripts/Scipts for other/Sheldon_TreadmillScript/', 10, 45)

10 in this eg. correspond to seconds before the shock
45 in this eg. correspond to seconds after the shock

The output includes:
	1) csv data clean up version of the original files with duration
	2) figure with pre and post shock for the files of interest
	3) csv data of pre and post shock for the 

### for habituation
	This generate an output for habituation of day4 and day5 (ToDo: modify to create function and input arguments of day of habituation [1] or [1 2 3 4 5]). This is also exclusively restricted to period of time of 20 min or less. If the last event is occuring at 5 min that would be the last value, an implementation of the DONE! status should be done to be sure when the animal was taken off
	1) create a folder called expinfo
		* the output will be placed in this folder as well
	2) place the genotype csv called 'sIDgeno.csv' with sID column and Genotype
	3) important currently expectation is that genotype is eg. HET or WT (NOT het Het or wt Wt)
		* this can be changed in the scripts


### for multi parameter testing

paramspre=[10, 12, 15]; % list of the preshock interval of interest
parampost=[20, 30, 40]; % list of the postshock interval of interest

for iparam=1:length(paramspre)

	treadmill('/home/rum/Desktop/Treadmill/', paramspre(iparam), parampost(iparam))

end