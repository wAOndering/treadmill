% for the treadmill the distance are expressed in millimiter


% select the files interested in
function importTMdata = importfile(pathDir, timeWindow, preShock)

% default for the function
% if nargin<=2
% 	%pathDir= '/home/rum/Dropbox (Scripps Research)/RumScripts/Scipts for other/Sheldon_TreadmillScript/';
pathDir='C:\Users\Windows\Desktop\SyngapKO 9-19-19 shock\SyngapKO 9-19-19 shock teraterm'
preShock="yes";
timeWindow=20; % time window in minutes
% end

cd(pathDir);
% outputFolder=['output - ' 'preS' num2str(preShockWindow) 's - postS' num2str(postShockWindow) 's'];
% mkdir(outputFolder);

% import the data for the genotype
genoT=readtable('expinfo/sIDgeno.csv')
if preShock=="yes"
	timeWindow=4;
	files = dir('*shock.csv');
else
	files = dir('*hab.csv');
end

figure1=figure('position', [619 603 506 341])

%%% LOOP to set up the figure


if preShock=="no"
sIDall=[]
	for jj=1:length(files)
	 	% display(files(jj).name)
	% end
		sIDtmp=files(jj).name;
		sIDtmp=sIDtmp(1:end-4);
		sIDtmp=split(sIDtmp,'d');
		dtmp=split(sIDtmp{2},'s');
		sIDtmp{2}=dtmp{1};
		sIDall=[sIDall; sIDtmp{2}];

	end
	sIDall=str2num(sIDall);
	sIDall=max(sIDall);
	else
	sIDall=1;
end





%%% LOOP to extract all the data
mainMat=[];
detailTab=[];
for ii=1:length(files)
% OPEN FILE	
	display(files(ii).name);

if preShock=="no"
	sIDtmp=files(ii).name;
	sIDtmp=sIDtmp(1:end-4);
	sIDtmp=split(sIDtmp,'d');
	dtmp=split(sIDtmp{2},'s');
	sIDtmp{2}=dtmp{1};
	pltID=str2num(sIDtmp{2});
else
	sIDtmp=files(ii).name;
	sIDtmp=sIDtmp(1:end-4);
	sIDtmp=split(sIDtmp,'s');
	sIDtmp{2}='0';
end

	animalID=files(ii).name(1:end-4);
	T=importfile(files(ii).name);

	genoTmp=genoT(find(genoT.sID==str2num(sIDtmp{1})),'Genotype').Genotype{1};
	% information about the table
		% T.Properties
		% varfun(@class,T,'OutputFormat','cell')


		% identify true start and end of the file
	endF=find(T.motionCat == "motion "); % identify the start of the file

		% in the file NaT not a date correspond to the begin and the end fo the trial
		% this is because the cell motion is followed by NaT row
		% and becasue the date is combien with 'DONE!! '


	if isempty(endF)
		endF=ismissing(T.eventTime); % identify the start and end of the value of interest see description above
		endF=find(endF==1); % obtain the row index for those values
		if isempty(endF)
			T=T(1:end,:);
		else
			T=T(endF(1)-1:end,:);
		end
	else
		T=T(endF:end,:);
	end

	% the following is structured this way to have the thing starting when motionCat is motion
			% if length(endF)<=2
			% T=T(endF(1)-1:end,:); % subset the table to the row of interest
			% else
			% T=T(endF(2)-1:end,:);	
			% end

	T.distance(1)=0;
	T.speed(1)=0;
	T(2,:)=[];

	% add the table the duration from the start
	T.timeFromStart=T.eventTime-T.eventTime(1);

% CLEANING UP MISSING VALUE
	% remove the error for each file
	TF=ismissing(T);

	T(any(TF,2),:);% display all the line that have missing values
	newT=T(~any(TF,2),:);% new table with no missing values
	newT.timeFromStart=duration(newT.timeFromStart, 'Format', 'hh:mm:ss.SSSS'); % change the precision of the duration
	newT.distance=newT.distance-newT.distance(1); % calculate the distance from the actual true beginning of the the trial
	newT.distStep=[nan; diff(newT.distance)];

	newT.distStep(isnan(newT.distStep))=0;
	newT{newT.motionCat == "F  ", 'distanceCat'}=cumsum(newT(find(newT.motionCat == "F  "),:).distStep);
	newT{newT.motionCat == "B  ", 'distanceCat'}=cumsum(newT(find(newT.motionCat == "B  "),:).distStep);
	% save the write table
	if preShock=="yes"
	writetable(newT,[animalID '_cleanPreS.txt'],'Delimiter',',');% save the clean up version of the file
	else
	writetable(newT,[animalID '_clean.txt'],'Delimiter',',');% save the clean up version of the file
	end

	% to create a combined table that can be called in python using seaborn for graphing
	newT.sID(:,1)=str2num(sIDtmp{1});
	newT.habDay(:,1)=str2num(sIDtmp{2});

	newT.timeFromStart=duration(newT.timeFromStart, 'Format', 'hh:mm'); %revert the format for ploting
	% convert the time from start in seconds and subset the data to 1200 seconds
	newT.timeFromStart=seconds(newT.timeFromStart);
	if newT.timeFromStart(end)>timeWindow*60
		newT=newT(find(newT.timeFromStart <= timeWindow*60),:);
	end

	% make a table that contains all the data
	detailTab=[detailTab;newT];
	size(detailTab)

	%%% TO DO %%%%
	% insert a condition if the samples do not match the data then
	% ignor 

	% extract the key values from the file
	distB=sum(newT.distStep(find(newT.motionCat == "B  ")));
	distF=sum(newT.distStep(find(newT.motionCat == "F  ")));

	tmpMat=[newT.timeFromStart(end),distB,distF, str2num(sIDtmp{1}), str2num(sIDtmp{2})];
	mainMat=[mainMat;tmpMat];

	% output some plot
		subplot(2,max(sIDall),pltID)
			if genoTmp == "wt"
			plot(newT.timeFromStart(find(newT.motionCat == "F  ")), newT.distanceCat(find(newT.motionCat == "F  ")), 'b')
			hold on
			else
			plot(newT.timeFromStart(find(newT.motionCat == "F  ")), newT.distanceCat(find(newT.motionCat == "F  ")), 'r')
			hold on
			end	
			ylabel(['Distance (mm)'])
			xlabel(['time (s)'])
			title(['Day ', sIDtmp{2}, ' forward run ', num2str(timeWindow), 'min'])
		subplot(2,max(sIDall),pltID+max(sIDall))
			if genoTmp == "wt"
			plot(newT.timeFromStart(find(newT.motionCat == "B  ")), newT.distanceCat(find(newT.motionCat == "B  ")), 'b')
			hold on
			else
			plot(newT.timeFromStart(find(newT.motionCat == "B  ")), newT.distanceCat(find(newT.motionCat == "B  ")), 'r')
			hold on
			end	
			ylabel(['Distance (mm)'])
			xlabel(['time (s)'])
			title(['Day ', sIDtmp{2}, ' backward run ', num2str(timeWindow), 'min'])
end 

%% combine with the genotype

if preShock=="yes"
saveas(figure1, ['expinfo',filesep,'overviewPreS.png']);
else
saveas(figure1, ['expinfo',filesep,'overview.png']);
end

mainMat=array2table(mainMat,...
'VariableNames',{'timeinSeconds','bckRun','fwdRun','sID','habDay'});
mainMat=join(mainMat, genoT, 'key', 'sID');


detailTab=join(detailTab, genoT, 'key', 'sID');

if preShock=="yes"
writetable(detailTab,['expinfo',filesep,'summaryDetailsPreS.csv'],'Delimiter',','); % save the data
writetable(mainMat,['expinfo',filesep,'summaryPreS.csv'],'Delimiter',','); % save the data
else
writetable(detailTab,['expinfo',filesep,'summaryDetails.csv'],'Delimiter',','); % save the data
writetable(mainMat,['expinfo',filesep,'summary.csv'],'Delimiter',','); % save the data
end

system("Rscript Rplot.r")

