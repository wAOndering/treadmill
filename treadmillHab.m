% for the treadmill the distance are expressed in millimiter


% select the files interested in
function importTMdata = importfile(pathDir, timeWindow)

% default for the function
% if nargin<=2
% 	%pathDir= '/home/rum/Dropbox (Scripps Research)/RumScripts/Scipts for other/Sheldon_TreadmillScript/';
pathDir='C:\Users\Windows\Desktop\SyngapKO 9-19-19 shock\SyngapKO 9-19-19 shock teraterm'
timeWindow=20; % time window in minutes
% end

cd(pathDir);
% outputFolder=['output - ' 'preS' num2str(preShockWindow) 's - postS' num2str(postShockWindow) 's'];
% mkdir(outputFolder);

% import the data for the genotype
genoT=readtable('expinfo/sIDgeno.csv')
files = dir('*hab.csv');
figure1=figure('position', [619 603 506 341])

%%% LOOP to set up the figure
sIDall=[]
for jj=1:length(files)
 	% display(files(jj).name)
% end
	sIDtmp=files(jj).name;
	sIDtmp=sIDtmp(1:end-4);
	sIDtmp=split(sIDtmp,'d');
	dtmp=split(sIDtmp{2},'s');
	sIDtmp{2}=dtmp{1};
	sIDall=[sIDall; sIDtmp{2}]
end

sIDall=str2num(sIDall)
sIDall=max(sIDall)


%%% LOOP to extract all the data
mainMat=[];
detailTab=[];
for ii=1:length(files)
% OPEN FILE	
	display(files(ii).name);

	sIDtmp=files(ii).name;
	sIDtmp=sIDtmp(1:end-4);
	sIDtmp=split(sIDtmp,'d');
	dtmp=split(sIDtmp{2},'s');
	sIDtmp{2}=dtmp{1};
	pltID=str2num(sIDtmp{2});

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
	writetable(newT,[animalID '_clean.txt'],'Delimiter',',');% save the clean up version of the file
	% to create a combined table that can be called in python using seaborn for graphing
	newT.sID(:,1)=str2num(sIDtmp{1});

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
saveas(figure1, ['expinfo',filesep,'overview.png']);

mainMat=array2table(mainMat,...
'VariableNames',{'timeinSeconds','bckRun','fwdRun','sID','habDay'});
mainMat=join(mainMat, genoT, 'key', 'sID');


detailTab=join(detailTab, genoT, 'key', 'sID');

writetable(detailTab,['expinfo',filesep,'summaryDetails.csv'],'Delimiter',','); % save the data
writetable(mainMat,['expinfo',filesep,'summary.csv'],'Delimiter',','); % save the data

system("Rscript Rplot.r")

%% 
% create information of total distnance


% merge table in matlab
% import the genotype table
% merge table with join







% % SHOCK related 
% 	%obtain the index for the shock
% 	shock=find(T.motionCat == "SHOCK!! "); % select all the shock
% 	shockTable=T(shock,:); % display the table index for the shock
% 	% Optain the shock interval
% 		shockEvent=T.eventTime(shock,:);
% 		shockInter=shockEvent(1:8)-shockEvent(2:9);
% 		shockDetection=-duration(00,0,80,0);
% 		idxMissingShock=find(shockInter<=shockDetection);
		
% 		% to deal with potential missing shocks
% 		if find(shockInter<=shockDetection)>=1
% 			manualShockAll=[];
% 			for iiMS=1:length(idxMissingShock)
% 				tlower=shockEvent(idxMissingShock(iiMS))+duration(00,0,4,0); % add 4 second to the window of the first shock
% 				tupper=shockEvent(idxMissingShock(iiMS)+1);
% 				winWmissing=newT(isbetween(newT.eventTime,tlower,tupper),:);
% 				manualShock=find(winWmissing.speed==max(winWmissing.speed));
% 				manualShock=winWmissing.eventTime(manualShock)-duration(00,0,4,0); % place teh manual shock 4 sec before max velocity
% 				manualShockAll=[manualShockAll; manualShock];
% 			end

% 			shockEvent=[shockEvent; manualShockAll];
% 			shockEvent=sort(shockEvent);

% 			shockTable=array2table(shockEvent,...
% 			'VariableNames',{'eventTime'});
% 			shockTable.timeFromStart = shockTable.eventTime-T.eventTime(1);
% 			shockTable.Manual=zeros(length(shockTable.timeFromStart),1);
% 			shockTable.Manual(find(shockTable.eventTime == manualShockAll),:)=1;

% 			writetable(shockTable,[animalID '_shock.txt'],'Delimiter',',') % save the clean up version of the file

% 			display('!!! some SHOCKS were NOT registered !!!');
% 			display('The following shocks were manually added:')
% 			display(manualShockAll-T.eventTime(1))
% 		end


% % SHOCK ANALYSIS
% 	% look at the first before XX seconds
% 	preShockDur=duration(00,0,preShockWindow,0);
% 	finalMatrix=[];
% 	for preWin= 1:length(shockTable.eventTime)-1
% 		tlower=shockTable.eventTime(preWin)-preShockDur;
% 		tupper=shockTable.eventTime(preWin);

% 		% this is present as some iteration may not occur if the animal is not running
% 		if sum(isbetween(newT.eventTime,tlower,tupper))==0
% 			matrix=[preWin 0 0 0 -preShockWindow str2num(animalID)];
% 		else	
% 			WinTable=newT(isbetween(newT.eventTime,tlower,tupper),:);
% 			distanceWin=WinTable.distance(end)-WinTable.distance(1);
% 			matrix=[preWin sum(WinTable.speed) mean(WinTable.speed) distanceWin(1) -preShockWindow str2num(animalID)];
% 		end

% 		finalMatrix=[finalMatrix;matrix];
% 	end
	
% 	preWinTable=array2table(finalMatrix,...
% 	'VariableNames',{'shock','speedSum','speedAvg', 'distanceWin', 'shockWin', 'animalID'});
	
% 	% look at the first after XX seconds
% 	postShockDur=duration(00,0,postShockWindow,0);
	
% 	finalMatrix=[];
% 	for postWin= 1:length(shockTable.eventTime)-1
% 		tlower=shockTable.eventTime(postWin);
% 		tupper=shockTable.eventTime(postWin)+postShockDur;
		
% 		WinTable=newT(isbetween(newT.eventTime,tlower,tupper),:);
% 		distanceWin=WinTable.distance(end)-WinTable.distance(1);
% 		matrix=[postWin sum(WinTable.speed) mean(WinTable.speed) distanceWin(1) postShockWindow str2num(animalID)];
% 		finalMatrix=[finalMatrix;matrix];
% 	end
	
% 	postWinTable=array2table(finalMatrix,...
% 	'VariableNames',{'shock','speedSum','speedAvg', 'distanceWin', 'shockWin', 'animalID'});

% 	% concatenate the array
% 	shockWinTable=[preWinTable;postWinTable];
% 	% save the table as  csv


% % PLOT 

% 	titleTxt=["speedSum","speedAvg","Distance"];
% 	figure1=figure('position', [3666         212        1065         588]);
% 	for pli=2:4
% 		subplot(4,3,pli-1)
% 		plot(preWinTable(:,pli).(1))
% 		hold on
% 		plot(postWinTable(:,pli).(1))
% 		title(titleTxt(pli-1))
% 		ylabel(titleTxt(pli-1))
% 		xlabel('SHOCK')
% 		if pli==4
% 		legend([num2str(preShockWindow) 's preS'],[num2str(postShockWindow) 's postS'])
% 		end
% 		set(gca,'TickDir','out');
% 	end

% 	%plot the time series
% 	%get(gcf,'Position');
% 	subplot(4,3,4:6)
% 	plot(newT.timeFromStart,newT.speed, 'b'); %timeFromStart / eventTime
% 	hold on
% 	% plot line when the shock happen
% 		y1=get(gca,'ylim'); % set the limit to plot 
% 		for si=1:length(shockTable.eventTime)-1
% 			x1 = shockTable.timeFromStart(si); % timeFromStart / eventTime
% 			plot([x1 x1], y1, 'r');
% 		end

% 		plot(newT.timeFromStart,newT.speed, 'b'); %timeFromStart / eventTime
% 		hold on

% 		title([animalID ' ' outputFolder]);
% 		%xlabel('Time (min)') ;
% 		ylabel('Speed');
% 		set(gca,'TickDir','out');
% 		axis1=gca();

% 	subplot(4,3,7:9)
% 	plot(newT.timeFromStart(find(newT.motionCat == "F  ")),newT.speed(find(newT.motionCat == "F  ")), 'b'); %timeFromStart / eventTime
% 	hold on
% 	% plot line when the shock happen
% 			y1=get(gca,'ylim'); % set the limit to plot 
% 			for si=1:length(shockTable.eventTime)-1
% 				x1 = shockTable.timeFromStart(si); % timeFromStart / eventTime
% 				plot([x1 x1], y1, 'r');
% 			end

% 			plot(newT.timeFromStart(find(newT.motionCat == "F  ")),newT.speed(find(newT.motionCat == "F  ")), 'b'); %timeFromStart / eventTime
% 			hold on

% 			%title([animalID ' ' outputFolder]);
% 			%xlabel('Time (min)') ;
% 			ylabel('FW-Speed');
% 			set(gca,'TickDir','out');
% 			axis2=gca();
	
% 	subplot(4,3,10:12)
% 	plot(newT.timeFromStart(find(newT.motionCat == "B  ")),newT.speed(find(newT.motionCat == "B  ")), 'b'); %timeFromStart / eventTime
% 	hold on
% 	% plot line when the shock happen
% 			y1=get(gca,'ylim'); % set the limit to plot 
% 			for si=1:length(shockTable.eventTime)-1
% 				x1 = shockTable.timeFromStart(si); % timeFromStart / eventTime
% 				plot([x1 x1], y1, 'r');
% 			end

% 			plot(newT.timeFromStart(find(newT.motionCat == "B  ")),newT.speed(find(newT.motionCat == "B  ")), 'b'); %timeFromStart / eventTime
% 			hold on

% 			%title([animalID ' ' outputFolder]);
% 			%xlabel('Time (min)') ;
% 			ylabel('BK-Speed');
% 			set(gca,'TickDir','out');
% 			axis3=gca();
% 			linkaxes([axis1,axis2,axis3], 'x');



% % SAVE
% 	% save the figure
% 	saveas(figure1, [pathDir,outputFolder,filesep,animalID,' ' outputFolder,'.png']);
% 	close all
% 	% save the files
% 	writetable(shockWinTable,[pathDir,outputFolder,filesep,animalID ' ' outputFolder,'.txt'],'Delimiter',',') % save the shockTable

% end