%% UT Austin Water Demand
% This code helps to examine water consumption trends for buildings across
% the the UT Austin campus. A variety of data visualizations are produced to
% understand water use. Within this code, there are also a set of toggles or 
% options. Some of these include: the use of cleaned vs.
% uncleaned data, the full time period of data available or solely the
% shared period of interest, monthly or daily demand data, and the ability to look at specific building
% classes or combinations of them.
%% Code Toggles
clc
clear
close all

%VERY IMPORTANT --- time_of_interest=1 indicates that we are looking at daily data
%while time_of_interest=0 indicates monthly data
time_of_interest=1; %options 'time_of_interest'=1 or 'time_of_interest'=0

%VERY IMPORTANT --- conditioned=1 indicates that we are looking at conditioned data
%while conditioned=0 indicates non-conditioned data (i.e. Anomalies are
%not removed)We want to use conditioned data when looking at campus
%wide metrics/analysis (only toggle unconditioned to see difference
%before and after conditioning)
conditioned=1; %options 'conditioned'=1 or 'conditioned'=0

%VERY IMPORTANT --- setting below = 0 prohibits individual graphs from
%showing up
graph=0;

%VERY IMPORTANT --- This toggle is to set the filenames of interest or in other words which
%buildings we will analyze
F_N=1;

    %1=all buildings, 
    %2=mix of buildings, 
    %3=small mix of buildings, 
    %4=housing(H), 
    %5=classroom&academic(CA),
    %6=operations&administration(OA), 
    %7=PublicAssembly&Multi-Purpose(PA),
    %8=ResearchLaboratories(RL)
    
%Important --- this toggles the titles of all figures off and on ... 1=titles off
%0=titles on
title_toggle=1;

%Pre-define font and marker size for all plots
set(0, 'defaultTextFontSize',13);
set(0,'defaultAxesFontSize',13)
marker_size=75;
%Deine which dates we are interested in for daily WUI profiles 
daily_date_range={'2015-02-01 00:00:00','2015-02-10 00:00:00'};

%% Data Import
% Import building specific attributes (gross square feet, filename,abbreviation, etc.) for all buildings
cd C:\Users\Michael\Documents\Research\Water\Import_Excel_Files
[BN,Abb,FN,BuildingType,Year,GSF,Water] = import_master_sheet('Master_sheet.xlsx','Sheet1',2,239);

% Collecting building filenames by building type
filenames_CA={'water_AHG.csv'; 'water_ART.csv'; 'water_JES.csv'; 'water_BEN.csv';...
    'water_BUR.csv'; 'water_CAL.csv'; 'water_CBA.csv'; 'water_DFA.csv';...
    'water_GAR.csv'; 'water_GDC.csv'; 'water_SZB.csv'; 'water_GOL.csv';...
    'water_GSB.csv'; 'water_CMA.csv'; 'water_JON.csv'; 'water_CLA.csv';...
    'water_MEZ.csv'; 'water_MRH.csv'; 'water_NUR.csv'; 'water_PAR.csv'; 'water_HRH.csv'; 'water_SEA.csv';...
    'water_SSW.csv'; 'water_SRH.csv'; 'water_TNH.csv'; 'water_UTC.csv'; 'water_WMB.csv';...
    'water_HSM.csv'};
%'water_BTL.csv'; 'water_BRB.csv'; 'water_WIN.csv'; 'water_BEL.csv';
%'water_GEA.csv'; 'water_SUT.csv'; 'water_BAT.csv';
filenames_CA_Struct={'AHG','ART','JES','BEN','BUR','CAL','CBA','DFA','GAR','GDC','SZB',...
    'GOL','GSB','CMA','JON','CLA','MEZ','MRH','NUR','PAR','HRH','SEA','SSW','SRH','TNH','UTC',...
    'WMB','HSM'};
%'BAT',
filenames_H={'water_AND.csv'; 'water_BLD.csv'; 'water_BHD.csv'; 'water_CRD.csv'; 'water_JCD.csv';...
    'water_MHD.csv'; 'water_PHD.csv'; 'water_SJH.csv'};
%'water_LTD.csv''water_CRH.csv' this not due to 1/1/2025;
filenames_H_Struct={'AND','BLD','BHD','CRD','JCD','MHD','PHD','SJH'};
%'CRH',
filenames_RL={'water_ARC.csv'; 'water_BME.csv'; 'water_CPE.csv'; 'water_EPS.csv';...
    'water_ECJ.csv'; 'water_PAT.csv'; 'water_JGB.csv'; 'water_MBB.csv'; 'water_NMS.csv'; 'water_NHB.csv';...
    'water_PHR.csv'; 'water_WEL.csv'; 'water_WRW.csv'};
filenames_RL_Struct={'ARC','BME','CPE','EPS','ECJ','PAT','JGB','MBB','NMS','NHB','PHR','WEL','WRW'};
%'water_ETC.csv';'ETC' this not due to 1/1/2025,
filenames_OA={'water_EAS.csv'; 'water_MNC.csv'; 'water_NOA.csv'};
filenames_OA_Struct={'EAS','MNC','NOA'};

filenames_PA={'water_CDL.csv'; 'water_DCP.csv'; 'water_UTX.csv'; 'water_ERC.csv'; 'water_GRE.csv';...
    'water_HRC.csv'; 'water_BMA.csv'; 'water_TCC.csv'; 'water_TSC.csv'; 'water_LBJ.csv'; 'water_PAC.csv';...
    'water_PCL.csv'; 'water_FAC.csv'; 'water_RSC.csv'; 'water_MFH.csv'; 'water_SAC.csv';...
    'water_SSB.csv'; 'water_TMM.csv'; 'water_UNB.csv'};
%; 'water_STD.csv'
filenames_PA_Struct={'CDL','DCP','UTX','ERC','GRE','HRC','BMA','TCC','TSC','LBJ','PAC','PCL',...
    'FAC','RSC','MFH','SAC','SSB','TMM','UNB'};

filenames_mixed_bag={'water_AHG.csv';'water_DCP.csv'; 'water_UTX.csv';'water_MNC.csv'; 'water_NOA.csv'; 'water_BME.csv'; 'water_CPE.csv'; 'water_BLD.csv'; 'water_BHD.csv';'water_ART.csv'; 'water_BAT.csv';'water_AND.csv';'water_ARC.csv';'water_EAS.csv';'water_CDL.csv';};
filenames_mixed_bag_Struct={'AHG','DCP','UTX','MNC','NOA','BME','CPE','BLD','BHD','ART',...
    'BAT','AND','ARC','EAS','CDL'};

filenames_master=[filenames_CA; filenames_H; filenames_RL; filenames_OA; filenames_PA]; %List of all buildings
filenames_master_Struct=[filenames_CA_Struct, filenames_H_Struct, filenames_RL_Struct, filenames_OA_Struct, filenames_PA_Struct];

filenames_mixed_bag_small={'water_AHG.csv'; 'water_SSW.csv'; 'water_NOA.csv'; 'water_BME.csv'; ...
    'water_CPE.csv'; 'water_BLD.csv'; 'water_BHD.csv'; ...
    'water_ARC.csv'; 'water_JCD.csv';'water_CDL.csv'};

filenames_mixed_bag_small_Struct={'AHG','SSW','NOA','BME','CPE','BLD','BHD',...
    'ARC','JCD','CDL'};

%Can ignore this (later used for pie chart(had to define before the for
%loop))
sumCAWaterGallonsPOI=0;
sumHWaterGallonsPOI=0;
sumRLWaterGallonsPOI=0;
sumOAWaterGallonsPOI=0;
sumPAWaterGallonsPOI=0;

if F_N==1
    filenames=filenames_master;
    filenames_struct=filenames_master_Struct;
elseif F_N==2
    filenames=filenames_mixed_bag;
    filenames_struct=filenames_mixed_bag_Struct;
elseif F_N==3
    filenames=filenames_mixed_bag_small;
    filenames_struct=filenames_mixed_bag_small_Struct;
elseif F_N==4
    filenames=filenames_H;
    filenames_struct=filenames_H_Struct;
elseif F_N==5
    filenames=filenames_CA;
    filenames_struct=filenames_CA_Struct;
elseif F_N==6
    filenames=filenames_OA;
    filenames_struct=filenames_OA_Struct;
elseif F_N==7
    filenames=filenames_PA;
    filenames_struct=filenames_PA_Struct;
elseif F_N==8
    filenames=filenames_RL;
    filenames_struct=filenames_RL_Struct;
else
end

%% For loop to generate Data Structure 
for i=1:length(filenames)
    
    % Import date and demand as a function of file name (water_Abb.csv)
    % Using function to bring in date and demand for specific building
    cd C:\Users\Michael\Documents\Research\Water\Import_Excel_Files
    [DateTime,WaterGallons] = date_and_demand(filenames{i}); % import specific building demand time series
    cd C:\Users\Michael\Documents\Research\Water\Import_Excel_Files
    index = find(strcmp(FN, filenames{i})); % Finding the building we are concerned with
    B_GSF= GSF(index); % finding GSF for specific building
    Yeari=Year(index);
    Yeari=str2double(Yeari);
    WUI=WaterGallons./B_GSF; % compute WUI
    WUI_avg=mean(WUI); % computing average WUI
    Tot_dem=sum(WaterGallons);
    Tot_WUI=Tot_dem/B_GSF;
    
    %Conditioning Data to Only Look at Shared Period of Interest (POI)
    firstdate = datetime('05/01/2014 00:00','InputFormat','MM/dd/yyyy hh:ss'); %Earliest Shared Date between all data
    lastdate = datetime('07/04/2017 00:00','InputFormat','MM/dd/yyyy hh:ss'); %Latest Shared Date between all data
    index2=find((firstdate<=DateTime) & (DateTime<=lastdate)); %Find dates... below in structure DateTime and WaterGallons are calculated for POI
    WUIPOI=WaterGallons(index2)./B_GSF; % compute WUI for POI
    WUI_avgPOI=mean(WaterGallons(index2)); % computing average WUI for POI
    Tot_demPOI=sum(WaterGallons(index2));
    Tot_WUIPOI=Tot_demPOI/B_GSF;
    
    
    %Process of converting data into monthly sums
    X = yyyymmdd(DateTime);
    T=table();
    T.year=floor(X/10000);
    T.mm=floor((X-T.year*10000)/100);
    T.dd=X-T.year*10000-T.mm*100;
    T.WaterGallons=WaterGallons;
    T.WUI=WUI;
    Y=grpstats(T,{'year','mm'},'sum','DataVars',{'WaterGallons','WUI'});
    firstDayOfMonth=[01 00 00 00];
    B = repmat(firstDayOfMonth,length(Y.year),1);
    Z=[Y.year Y.mm B];
    t = datetime(Z);
    t.Format='MM/dd/yyyy hh:mm';
    index3=find((firstdate<=t) & (t<=lastdate)); %Find dates... below in structure DateTime and WaterGallons are calculated for POI on monthly increments
    
    %Creating Time Periods for Period of Interest Either on Daily or
    %Monthly Basis
    DateTimePOIDaily=DateTime(index2);
    WaterGallonsPOIDaily=WaterGallons(index2);
    WaterGallonsPOIDailyAVG=mean(WaterGallonsPOIDaily);
    Tot_WUIPOI_monthly=Tot_demPOI/B_GSF;
    Pd_Ad=WaterGallonsPOIDaily./WaterGallonsPOIDailyAVG;

    %Constructing the structure for each building
    Data.(Abb{index}) = struct('GSF',B_GSF,'DateTime',DateTime, ...
        'WaterGallons',WaterGallons,'Average_Daily_Water_Demand_POI',WaterGallonsPOIDailyAVG,'WUI',WUI,'WUI_avg',WUI_avg,'WUI_avg_daily',WUI_avg, ...
        'Total_Demand',Tot_dem,'Net_Demand',Tot_WUI,'Date_of_Construction',Yeari,...
        'Building_Type',BuildingType(index),'PD_AD_Ratio_POI',Pd_Ad,'DateTimePOIDaily',DateTimePOIDaily,...
        'WaterGallonsPOIDaily',WaterGallonsPOIDaily,'WUIPOIDaily',WUIPOI,'WUI_avg_POI',WUI_avgPOI, ...
        'Total_Demand_POI',Tot_demPOI,'Net_Demand_POI',Tot_WUIPOI,'DateTime_Month',t,...
        'WUI_Month',Y.sum_WUI,'WUI_avg_monthly',mean(Y.sum_WUI),'WaterGallons_Month',Y.sum_WaterGallons,...
        'DateTime_Month_POI',t(index3),'WUI_Month_POI',Y.sum_WUI(index3),...
        'WaterGallons_Month_POI',Y.sum_WaterGallons(index3),'Net_Demand_POI_monthly',Tot_WUIPOI_monthly,...
        'Total_Demand_POI_Monthly',Tot_demPOI);
    %char(Abb(index))=struct('GSF',B_GSF,'DateTime',DateTime,'WaterGallons',WaterGallons,'WUI',WUI,'WUI_avg',WUI_avg);
    
    % Conditioning data
    monthly_dates=Data.(char(filenames_struct(i))).DateTime_Month_POI;
    monthly_demand=Data.(char(filenames_struct(i))).WaterGallons_Month_POI;
    daily_dates=Data.(char(filenames_struct(i))).DateTimePOIDaily;
    daily_demand=Data.(char(filenames_struct(i))).WaterGallonsPOIDaily;
    cd C:\Users\Michael\Documents\Research\Water\Main_Code\Data_Conditioning
    [conditioned_daily_dem_POI,conditioned_daily_dates_POI]=condition_usage_daily_water(2.5,60,daily_dates,daily_demand); %timeframe input has to be positive
    [conditioned_monthly_dem_POI,conditioned_monthly_dates_POI]=condition_usage_monthly_water(2,6,monthly_dates,monthly_demand); %timeframe input has to be positive
    cd C:\Users\Michael\Documents\Research\Water\Main_Code\Master_Code
    
    % Placing conditioned data into previously made structure
    [Data.(Abb{index})(:).Conditioned_POI_Daily_Demand]=conditioned_daily_dem_POI;
    [Data.(Abb{index})(:).Conditioned_POI_Daily_Dates]=conditioned_daily_dates_POI;
    [Data.(Abb{index})(:).Conditioned_POI_Monthly_Demand]=conditioned_monthly_dem_POI;
    [Data.(Abb{index})(:).Conditioned_POI_Monthly_Dates]=conditioned_monthly_dates_POI;
    
    % Being able to toggle on whether or not we are looking at
    % conditioned/un-conditioned data. If we use the below data structure,
    % all visualizations will only utilize cleaned data
    if conditioned==1
        Data.(Abb{index}) = struct('GSF',B_GSF,'DateTime',DateTime, ...
            'WaterGallons',WaterGallons,'Average_Daily_Water_Demand_POI',WaterGallonsPOIDailyAVG,...
            'WUI',conditioned_daily_dem_POI./B_GSF,'WUI_daily',conditioned_daily_dem_POI./B_GSF,'WUI_avg_daily',mean(conditioned_daily_dem_POI./B_GSF), ...
            'WUI_monthly',conditioned_monthly_dem_POI./B_GSF,'WUI_avg_monthly',mean(conditioned_monthly_dem_POI./B_GSF),'Total_Demand',Tot_dem,'Net_Demand',Tot_WUI,'Date_of_Construction',Yeari,...
            'Building_Type',BuildingType(index),'PD_AD_Ratio_POI',Pd_Ad,'DateTimePOIDaily',conditioned_daily_dates_POI,...
            'WaterGallonsPOIDaily',conditioned_daily_dem_POI,'WUIPOIDaily',conditioned_daily_dem_POI./B_GSF,'WUI_avg_POI',mean(conditioned_daily_dem_POI./B_GSF), ...
            'Total_Demand_POI',sum(conditioned_daily_dem_POI),'Net_Demand_POI',sum(conditioned_daily_dem_POI)./B_GSF,'DateTime_Month',conditioned_monthly_dates_POI,...
            'WUI_Month',conditioned_monthly_dem_POI./B_GSF,'WaterGallons_Month',Y.sum_WaterGallons,...
            'DateTime_Month_POI',conditioned_monthly_dates_POI,'WUI_Month_POI',conditioned_monthly_dem_POI./B_GSF,...
            'WaterGallons_Month_POI',conditioned_monthly_dem_POI,'Net_Demand_POI_monthly',sum(conditioned_monthly_dem_POI)./B_GSF,...
            'Total_Demand_POI_Monthly',sum(conditioned_monthly_dem_POI));
        [Data.(Abb{index})(:).Conditioned_POI_Daily_Demand]=conditioned_daily_dem_POI;
        [Data.(Abb{index})(:).Conditioned_POI_Daily_Dates]=conditioned_daily_dates_POI;
        [Data.(Abb{index})(:).Conditioned_POI_Monthly_Demand]=conditioned_monthly_dem_POI;
        [Data.(Abb{index})(:).Conditioned_POI_Monthly_Dates]=conditioned_monthly_dates_POI;
    else
    end
    
    %% Color coding each plot based on building type
    % This is where we specify the resolution of demand data(either monthly
    % or daily)
    
    if time_of_interest == 1
        WhichDateTimeConditioned='Conditioned_POI_Daily_Dates'; %Options [ 'Conditioned_POI_Daily_Dates' or 'Conditioned_POI_Monthly_Dates' ]
        WhichWaterGallonsConditioned='Conditioned_POI_Daily_Demand'; %Options [ 'Conditioned_POI_Daily_Demand' or 'Conditioned_POI_Monthly_Demand' ]
        WhichDateTime='DateTimePOIDaily'; %Options [ 'DateTime_Month_POI' or 'DateTimePOIDaily' ]
        WhichWaterGallons='WaterGallonsPOIDaily'; %Options [ 'WaterGallons_Month_POI' or 'WaterGallonsPOIDaily' ]
        WhichWUI='WUIPOIDaily'; % Options ['WUIPOIDaily' or 'WUI_Month_POI']
        months={'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
        
    else
        WhichDateTimeConditioned='Conditioned_POI_Monthly_Dates'; %Options [ 'Conditioned_POI_Daily_Dates' or 'Conditioned_POI_Monthly_Dates' ]
        WhichWaterGallonsConditioned='Conditioned_POI_Monthly_Demand'; %Options [ 'Conditioned_POI_Daily_Demand' or 'Conditioned_POI_Monthly_Demand' ]
        WhichDateTime='DateTime_Month_POI'; %Options [ 'DateTime_Month_POI' or 'DateTimePOIDaily' ]
        WhichWaterGallons='WaterGallons_Month_POI'; %Options [ 'WaterGallons_Month_POI' or 'WaterGallonsPOIDaily' ]
        WhichWUI='WUI_Month_POI'; % Options ['WUIPOIDaily' or 'WUI_Month_POI']
        months={'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
        
    end
    
    %The below code helps to determine the number of peak days for a given
    %building
    threshold_ratio=1.5;
    PD_AD_Count=zeros(length(Data.(char(Abb{index})).('PD_AD_Ratio_POI')),1);
    for t=1:length(Data.(char(Abb{index})).('PD_AD_Ratio_POI'))
        
        if Data.(char(Abb{index})).('PD_AD_Ratio_POI')(t) > ...
                threshold_ratio
            PD_AD_Count(t,1)=1;
        else
            PD_AD_Count(t,1)=0;
        end
        
    end
    
    X = yyyymmdd(DateTimePOIDaily);
    T=table();
    T.year=floor(X/10000);
    T.mm=floor((X-T.year*10000)/100);
    T.dd=X-T.year*10000-T.mm*100;
    T.PD_AD_Count=PD_AD_Count;
    Y=grpstats(T,{'year','mm'},'sum','DataVars',{'PD_AD_Count'});
    firstDayOfMonth=[01 00 00 00];
    B = repmat(firstDayOfMonth,length(Y.year),1);
    Z=[Y.year Y.mm B];
    t = datetime(Z);
    t.Format='MM/dd/yyyy hh:mm';
    index4=find((firstdate<=t) & (t<=lastdate));
    % Peak Day Plot is given below
    %         figure
    %         hold on
    %         plot(Data.(char(Abb{index})).('DateTime_Month_POI'),Y.sum_PD_AD_Count,'or')
    %         ylabel('Number of Peak Days')
    %         xlabel('Time')
    %         title(['Number of Peak Days Per Month for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
    %
    
    if Data.(char(Abb{index})).Building_Type == 'CA' % If our builiding is classroom or academic
        
        figure %WUI graph
        hold on
        plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWUI)),'r')
        xlabel('Date')
        ylabel('Water Use Intensity (Gal/ft2)')
        if title_toggle==0
            title(['Water Demand for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        % Here we are keeping a running total of demand over the course of
        % the period of interest for all CA buildings
        sumCAWaterGallonsPOI=sumCAWaterGallonsPOI+sum(Data.(char(Abb{index})).(char(WhichWaterGallons)));
        %Here we are making a average monthly demand plot for the builidng
        A=datevec(Data.(char(Abb{index})).(char(WhichDateTime)));
        for i=1:12
            indexerooni=find(A(:,2)==i);
            monthlyAvg(i,1)=mean(Data.(char(Abb{index})).(char(WhichWUI))(indexerooni));
        end
        figure
        hold on
        plot(monthlyAvg,'r')
        set(gca,'xtick',1:length(months),'XTickLabel',months,'XTickLabelRotation',270);
        ylabel('Average WUI Gallons/ft^2')
        if title_toggle==0
            title(['Seasonal Variation in WUI for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        
        if conditioned == 0 % if we are using conditioned data it is not necessary to compare before and after
            figure % This is the before cleaning plot
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'r')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            ylabel('Daily Water Demand (Gallons)')
            xlabel('Date')
            if title_toggle==0
                title('Pre-Conditioned')
            else
            end
            hold off
            
            figure % This is the after cleaning plot
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'r'...
                ,Data.(char(Abb{index})).(char(WhichDateTimeConditioned)),Data.(char(Abb{index})).(char(WhichWaterGallonsConditioned)),'b')
            ylabel('Daily Water Demand (Gallons)')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            xlabel('Date')
            if title_toggle==0
                title('Post-Conditioned Overlay')
            else
            end
            hold off
        else
        end
        
    elseif Data.(char(Abb{index})).Building_Type == 'H' %See CA code commenting for explanation
        figure
        hold on
        plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWUI)),'g')
        xlabel('Date')
        ylabel('Water Use Intensity (Gal/ft2)')
        if title_toggle==0
            title(['Water Demand for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        sumHWaterGallonsPOI=sumHWaterGallonsPOI+sum(Data.(char(Abb{index})).(char(WhichWaterGallons)));
        A=datevec(Data.(char(Abb{index})).(char(WhichDateTime)));
        for i=1:12
            indexerooni=find(A(:,2)==i);
            monthlyAvg(i,1)=mean(Data.(char(Abb{index})).(char(WhichWUI))(indexerooni));
        end
        figure
        hold on
        plot(monthlyAvg,'g')
        set(gca,'xtick',1:length(months),'XTickLabel',months,'XTickLabelRotation',270)
        ylabel('Average WUI Gallons/ft^2')
        if title_toggle==0
            title(['Seasonal Variation in WUI for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        if conditioned==0
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'g')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            ylabel('Daily Water Demand (Gallons)')
            xlabel('Date')
            if title_toggle==0
                title('Pre-Conditioned')
            else
            end
            hold off
            
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'g'...
                ,Data.(char(Abb{index})).(char(WhichDateTimeConditioned)),Data.(char(Abb{index})).(char(WhichWaterGallonsConditioned)),'b')
            ylabel('Daily Water Demand (Gallons)')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            xlabel('Date')
            if title_toggle==0
                title('Post-Conditioned Overlay')
            else
            end
            hold off
        else
        end
        
    elseif Data.(char(Abb{index})).Building_Type == 'RL' %See CA code commenting for explanation
        figure
        hold on
        plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWUI)),'k')
        xlabel('Date')
        ylabel('Water Use Intensity (Gal/ft2)')
        if title_toggle==0
            title(['Water Demand for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        sumRLWaterGallonsPOI=sumRLWaterGallonsPOI+sum(Data.(char(Abb{index})).(char(WhichWaterGallons)));
        A=datevec(Data.(char(Abb{index})).(char(WhichDateTime)));
        for i=1:12
            indexerooni=find(A(:,2)==i);
            monthlyAvg(i,1)=mean(Data.(char(Abb{index})).(char(WhichWUI))(indexerooni));
        end
        figure
        hold on
        plot(monthlyAvg,'k')
        set(gca,'xtick',1:length(months),'XTickLabel',months,'XTickLabelRotation',270)
        ylabel('Average WUI Gallons/ft^2')
        if title_toggle==0
            title(['Seasonal Variation in WUI for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        if conditioned==0
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'k')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            ylabel('Daily Water Demand (Gallons)')
            xlabel('Date')
            if title_toggle==0
                title('Pre-Conditioned')
            else
            end
            hold off
            
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'k'...
                ,Data.(char(Abb{index})).(char(WhichDateTimeConditioned)),Data.(char(Abb{index})).(char(WhichWaterGallonsConditioned)),'b')
            ylabel('Daily Water Demand (Gallons)')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            xlabel('Date')
            if title_toggle==0
                title('Post-Conditioned Overlay')
            else
            end
            hold off
        else
        end
        
    elseif Data.(char(Abb{index})).Building_Type == 'OA' %See CA code commenting for explanation
        figure
        hold on
        plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWUI)),'c')
        xlabel('Date')
        ylabel('Water Use Intensity (Gal/ft2)')
        if title_toggle==0
            title(['Water Demand for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        sumOAWaterGallonsPOI=sumOAWaterGallonsPOI+sum(Data.(char(Abb{index})).(char(WhichWaterGallons)));
        A=datevec(Data.(char(Abb{index})).(char(WhichDateTime)));
        for i=1:12
            indexerooni=find(A(:,2)==i);
            monthlyAvg(i,1)=mean(Data.(char(Abb{index})).(char(WhichWUI))(indexerooni));
        end
        figure
        hold on
        plot(monthlyAvg,'c')
        set(gca,'xtick',1:length(months),'XTickLabel',months,'XTickLabelRotation',270)
        ylabel('Average WUI Gallons/ft^2')
        if title_toggle==0
            title(['Seasonal Variation in WUI for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        if conditioned==0
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'c')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            ylabel('Daily Water Demand (Gallons)')
            xlabel('Date')
            if title_toggle==0
                title('Pre-Conditioned')
            else
            end
            hold off
            
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'c'...
                ,Data.(char(Abb{index})).(char(WhichDateTimeConditioned)),Data.(char(Abb{index})).(char(WhichWaterGallonsConditioned)),'b')
            ylabel('Daily Water Demand (Gallons)')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            xlabel('Date')
            if title_toggle==0
                title('Post-Conditioned Overlay')
            else
            end
            hold off
        else
        end
        
    else  %See CA code commenting for explanation
        figure
        hold on
        plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWUI)),'m')
        xlabel('Date')
        ylabel('Water Use Intensity (Gal/ft2)')
        if title_toggle==0
            title(['Water Demand for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        sumPAWaterGallonsPOI=sumPAWaterGallonsPOI+sum(Data.(char(Abb{index})).(char(WhichWaterGallons)));
        A=datevec(Data.(char(Abb{index})).(char(WhichDateTime)));
        for i=1:12
            indexerooni=find(A(:,2)==i);
            monthlyAvg(i,1)=mean(Data.(char(Abb{index})).(char(WhichWUI))(indexerooni));
        end
        figure
        hold on
        plot(monthlyAvg,'m')
        set(gca,'xtick',1:length(months),'XTickLabel',months,'XTickLabelRotation',270)
        ylabel('Average WUI Gallons/ft^2')
        if title_toggle==0
            title(['Seasonal Variation in WUI for ' char(Abb{index}) ' Building Type (' char(Data.(char(Abb{index})).Building_Type) ')'])
        else
        end
        hold off
        if conditioned==0
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'m')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            ylabel('Daily Water Demand (Gallons)')
            xlabel('Date')
            if title_toggle==0
                title('Pre-Conditioned')
            else
            end
            hold off
            
            figure
            hold on
            plot(Data.(char(Abb{index})).(char(WhichDateTime)),Data.(char(Abb{index})).(char(WhichWaterGallons)),'m'...
                ,Data.(char(Abb{index})).(char(WhichDateTimeConditioned)),Data.(char(Abb{index})).(char(WhichWaterGallonsConditioned)),'b')
            ylabel('Daily Water Demand (Gallons)')
            ylim([0 max(Data.(char(Abb{index})).(char(WhichWaterGallons)))])
            xlabel('Date')
            if title_toggle==0
                title('Post-Conditioned Overlay')
            else
            end
            hold off
        else
        end
        if graph==0
            close all
        else
        end
    end
    
end



close all


%% Creating Pie Chart of Total Water Consumption
% This is a raw demand data pie chart that takes the sum of all demand for
% a given building type over the period of interest
a=sumCAWaterGallonsPOI;
b=sumHWaterGallonsPOI;
c=sumRLWaterGallonsPOI;
d=sumOAWaterGallonsPOI;
e=sumPAWaterGallonsPOI;
sum_tot=a+b+c+d+e;

figure
labels={'CA ','H ','RL ','OA ','PA '};
h=pie([a b c d e]);
hText = findobj(h,'Type','text'); % text object handles
percentValues = get(hText,'String'); % percent values
txt = labels; % strings
combinedtxt = strcat(txt',percentValues); % strings and percent values
oldExtents_cell = get(hText,'Extent'); % cell array
oldExtents = cell2mat(oldExtents_cell); % numeric array
hText(1).String = combinedtxt(1);
hText(2).String = combinedtxt(2);
hText(3).String = combinedtxt(3);
hText(4).String = combinedtxt(4);
hText(5).String = combinedtxt(5);
colormap([[1 0 0];      %// red
    [0 1 0];      %// green
    [0 0 0];      %// black
    [0 1 1];      %// cyan
    [1 0 1]])  %//magenta
if title_toggle==0
    title('Percentage of Total Water Demand Over Period of Interest')
else
end
%% Creating Pie Chart of Extrapolated Total Water Consumption on UT with Ratios
%Numerator of coefficient is the total number of buildings within
%each building class across the UT campus
%Denominator is number of buildings with demand data within each building
%class within this study
a=(40/28)*sumCAWaterGallonsPOI;
b=(19/8)*sumHWaterGallonsPOI;
c=(19/13)*sumRLWaterGallonsPOI;
d=(18/3)*sumOAWaterGallonsPOI;
e=(26/19)*sumPAWaterGallonsPOI;

figure
labels={'CA ','H ','RL ','OA ','PA '};
h=pie([a b c d e]);
hText = findobj(h,'Type','text'); % text object handles
percentValues = get(hText,'String'); % percent values
txt = labels; % strings
combinedtxt = strcat(txt',percentValues); % strings and percent values
oldExtents_cell = get(hText,'Extent'); % cell array
oldExtents = cell2mat(oldExtents_cell); % numeric array
hText(1).String = combinedtxt(1);
hText(2).String = combinedtxt(2);
hText(3).String = combinedtxt(3);
hText(4).String = combinedtxt(4);
hText(5).String = combinedtxt(5);
colormap([[1 0 0];      %// red
    [0 1 0];      %// green
    [0 0 0];      %// black
    [0 1 1];      %// cyan
    [1 0 1]])  %//magenta
if title_toggle==0
    title('Extrapolated Percentage of Total Water Demand Over Period of Interest')
else
end

%% Total vs. Net Demand 
%Creating figure that shows Total Demand vs. Net Demand For building
%clusters
if time_of_interest == 1
    WhichWUI='WUI_daily'; % Options ['WUIPOIDaily' or 'WUI_Month_POI']
    WhichWUI_avg='WUI_avg_daily'; %Setting WUI_AVG which we want to look at
    WhichTot_dem='Total_Demand_POI'; %Setting Total Dem which we want to look at
    WhichNet_dem='Net_Demand_POI'; %Setting Net Demand which we want to look at
    months={'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
    
else
    WhichWUI='WUI_monthly'; % Options ['WUIPOIDaily' or 'WUI_Month_POI']
    WhichWUI_avg='WUI_avg_monthly'; %Setting WUI_AVG which we want to look at
    WhichTot_dem='Total_Demand_POI_Monthly'; %Setting Total Dem which we want to look at
    WhichNet_dem='Net_Demand_POI_monthly'; %Setting Net Demand which we want to look at
    months={'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
    
end


figure
for i=1:length(filenames)
    index = find(strcmp(FN, filenames{i}));
    %     plot(Data.(Abb{index}).DateTime,Data.(Abb{index}).WaterGallons)
    Sequential_Abb(i,1)=Abb(index);
    GSFi(i,1)=Data.(Abb{index}).('GSF');
    WUI_AVG_Total(i,1)=Data.(Abb{index}).(char(WhichWUI_avg));
    Total_Dem(i,1)=Data.(Abb{index}).(char(WhichTot_dem));
    Net_Dem(i,1)=Data.(Abb{index}).(char(WhichNet_dem));
    BType{i,1}=Data.(char(Abb{index})).Building_Type;
    hold on
    
    % Assigning color based on building type
    if Data.(char(Abb{index})).Building_Type == 'CA'
        plot(Net_Dem(i),Total_Dem(i),'or')
    elseif Data.(char(Abb{index})).Building_Type == 'H'
        plot(Net_Dem(i),Total_Dem(i),'og')
    elseif Data.(char(Abb{index})).Building_Type == 'RL'
        plot(Net_Dem(i),Total_Dem(i),'ok')
    elseif Data.(char(Abb{index})).Building_Type == 'OA'
        plot(Net_Dem(i),Total_Dem(i),'oc')
    else
        plot(Net_Dem(i),Total_Dem(i),'om')
    end
    
end
xlabel('Net Demand (gal/ft^2)')
ylabel('Total Demand(gal)')
if title_toggle==0
    title('Tot vs Net Water Demand for buildings at UT Austin')
else
end
h = zeros(3, 1);
h(1) = plot(NaN,NaN,'oc');
h(2) = plot(NaN,NaN,'or');
h(3) = plot(NaN,NaN,'ok');
h(4) = plot(NaN,NaN,'og');
h(5) = plot(NaN,NaN,'om');
legend(h, 'OA','CA','RL','H','PA','Location','northwest');

% We only want to do this analysis for data sets with more than one building
% classification 
if isequal(filenames,filenames_mixed_bag) || isequal(filenames,filenames_master) || isequal(filenames,filenames_mixed_bag_small)
    % Making Centroid Points
    BTypes={'OA','CA','RL','H','PA'};
    indexer=find(strcmp(BType, 'CA'));
    for i=1:length(indexer)
        CentroidCA=[sum(Net_Dem(indexer))/length(indexer) sum(Total_Dem(indexer))/length(indexer) ];
    end
    indexer=find(strcmp(BType, 'OA'));
    for i=1:length(indexer)
        CentroidOA=[sum(Net_Dem(indexer))/length(indexer) sum(Total_Dem(indexer))/length(indexer) ];
    end
    indexer=find(strcmp(BType, 'RL'));
    for i=1:length(indexer)
        CentroidRL=[sum(Net_Dem(indexer))/length(indexer) sum(Total_Dem(indexer))/length(indexer) ];
    end
    indexer=find(strcmp(BType, 'H'));
    for i=1:length(indexer)
        CentroidH=[sum(Net_Dem(indexer))/length(indexer) sum(Total_Dem(indexer))/length(indexer) ];
    end
    indexer=find(strcmp(BType, 'PA'));
    for i=1:length(indexer)
        CentroidPA=[sum(Net_Dem(indexer))/length(indexer) sum(Total_Dem(indexer))/length(indexer) ];
    end
    markersize=14;
    plot(CentroidPA(1),e,'om','markers',markersize)
    plot(CentroidH(1),b,'og','markers',markersize)
    plot(CentroidRL(1),c,'ok','markers',markersize)
    plot(CentroidCA(1),a,'or','markers',markersize)
    plot(CentroidOA(1),d,'oc','markers',markersize)
    
    plot(CentroidPA(1),CentroidPA(2),'sm','markers',markersize)
    plot(CentroidH(1),CentroidH(2),'sg','markers',markersize)
    plot(CentroidRL(1),CentroidRL(2),'sk','markers',markersize)
    plot(CentroidCA(1),CentroidCA(2),'+r','markers',markersize)
    plot(CentroidOA(1),CentroidOA(2),'+c','markers',markersize)
    hold off
    
    %Plotting just the centroids
    figure
    hold on
    markersize=14;
    scatter(CentroidPA(1),CentroidPA(2),marker_size,'om','filled','MarkerEdgeColor','k')
    scatter(CentroidH(1),CentroidH(2),marker_size,'og','filled','MarkerEdgeColor','k')
    scatter(CentroidRL(1),CentroidRL(2),marker_size,'ok','filled','MarkerEdgeColor','k')
    scatter(CentroidCA(1),CentroidCA(2),marker_size,'or','filled','MarkerEdgeColor','k')
    scatter(CentroidOA(1),CentroidOA(2),marker_size,'oc','filled','MarkerEdgeColor','k')
    
    xlabel('Net Demand (gal/ft^2)')
    xlim([0 120])
    ylabel('Average Total Demand(gal)')
    if title_toggle==0
        title('Tot vs Net Water Demand for UT Austin buildings')
    else
    end
    h = zeros(3, 1);
    h(1) = scatter(NaN,NaN,marker_size,'oc','filled','MarkerEdgeColor','k');
    h(2) = scatter(NaN,NaN,marker_size,'or','filled','MarkerEdgeColor','k');
    h(3) = scatter(NaN,NaN,marker_size,'ok','filled','MarkerEdgeColor','k');
    h(4) = scatter(NaN,NaN,marker_size,'og','filled','MarkerEdgeColor','k');
    h(5) = scatter(NaN,NaN,marker_size,'om','filled','MarkerEdgeColor','k');
    legend(h, 'OA','CA','RL','H','PA','Location','northwest');
    legend boxoff
    hold off
    
else
end


%% GSF vs. Total Demand
figure
for i=1:length(filenames)
    index = find(strcmp(FN, filenames{i}));
    %     plot(Data.(Abb{index}).DateTime,Data.(Abb{index}).WaterGallons)
    Sequential_Abb(i,1)=Abb(index);
    GSFi(i,1)=Data.(Abb{index}).('GSF');
    WUI_AVG_Total(i,1)=Data.(Abb{index}).(char(WhichWUI_avg));
    Total_Dem(i,1)=Data.(Abb{index}).(char(WhichTot_dem));
    Net_Dem(i,1)=Data.(Abb{index}).(char(WhichNet_dem));
    BType{i,1}=Data.(char(Abb{index})).Building_Type;
    hold on
    
    if Data.(char(Abb{index})).Building_Type == 'CA'
        plot(GSFi(i),Total_Dem(i),'or')
    elseif Data.(char(Abb{index})).Building_Type == 'H'
        plot(GSFi(i),Total_Dem(i),'og')
    elseif Data.(char(Abb{index})).Building_Type == 'RL'
        plot(GSFi(i),Total_Dem(i),'ok')
    elseif Data.(char(Abb{index})).Building_Type == 'OA'
        plot(GSFi(i),Total_Dem(i),'oc')
    else
        plot(GSFi(i),Total_Dem(i),'om')
    end
    
end
xlabel('GSF (ft^2)')
ylabel('Total Demand(gal)')
if title_toggle==0
    title('Tot Demand vs GSF for buildings at UT Austin')
else
end
h = zeros(3, 1);
h(1) = plot(NaN,NaN,'oc');
h(2) = plot(NaN,NaN,'or');
h(3) = plot(NaN,NaN,'ok');
h(4) = plot(NaN,NaN,'og');
h(5) = plot(NaN,NaN,'om');
legend(h, 'OA','CA','RL','H','PA','Location','northwest');
hold off

%% GSF vs. Net Demand
figure
for i=1:length(filenames)
    index = find(strcmp(FN, filenames{i}));
    %     plot(Data.(Abb{index}).DateTime,Data.(Abb{index}).Watergal)
    Sequential_Abb(i,1)=Abb(index);
    GSFi(i,1)=Data.(Abb{index}).('GSF');
    WUI_AVG_Total(i,1)=Data.(Abb{index}).(char(WhichWUI_avg));
    Total_Dem(i,1)=Data.(Abb{index}).(char(WhichTot_dem));
    Net_Dem(i,1)=Data.(Abb{index}).(char(WhichNet_dem));
    BType{i,1}=Data.(char(Abb{index})).Building_Type;
    hold on
   
    if Data.(char(Abb{index})).Building_Type == 'CA'
        scatter(GSFi(i),Total_Dem(i)/GSF(i),marker_size,'or','filled','MarkerEdgeColor','k')
    elseif Data.(char(Abb{index})).Building_Type == 'H'
        scatter(GSFi(i),Total_Dem(i)/GSF(i),marker_size,'og','filled','MarkerEdgeColor','k')
    elseif Data.(char(Abb{index})).Building_Type == 'RL'
        scatter(GSFi(i),Total_Dem(i)/GSF(i),marker_size,'ok','filled','MarkerEdgeColor','k')
    elseif Data.(char(Abb{index})).Building_Type == 'OA'
        scatter(GSFi(i),Total_Dem(i)/GSF(i),marker_size,'oc','filled','MarkerEdgeColor','k')
    else
        scatter(GSFi(i),Total_Dem(i)/GSF(i),marker_size,'om','filled','MarkerEdgeColor','k')
    end
    set(gca, 'XScale', 'log')
end
xlabel('GSF (ft^2)')
ylabel('Net Demand(Gal/ft^2)')
if title_toggle==0
    title('Net Demand vs GSF for buildings at UT Austin')
else
end
h = zeros(3, 1);
h(1) = scatter(NaN,NaN,marker_size,'oc','filled','MarkerEdgeColor','k');
h(2) = scatter(NaN,NaN,marker_size,'or','filled','MarkerEdgeColor','k');
h(3) = scatter(NaN,NaN,marker_size,'ok','filled','MarkerEdgeColor','k');
h(4) = scatter(NaN,NaN,marker_size,'og','filled','MarkerEdgeColor','k');
h(5) = scatter(NaN,NaN,marker_size,'om','filled','MarkerEdgeColor','k');
legend(h, 'OA','CA','RL','H','PA','Location','northwest');
legend boxoff  
hold off

%% Building Age vs. Total Demand
figure
for i=1:length(filenames)
    index = find(strcmp(FN, filenames{i}));
    Sequential_Abb(i,1)=Abb(index);
    GSFi(i,1)=Data.(Abb{index}).('GSF');
    Age(i,1)=Data.(Abb{index}).('Date_of_Construction');
    WUI_AVG_Total(i,1)=Data.(Abb{index}).(char(WhichWUI_avg));
    Total_Dem(i,1)=Data.(Abb{index}).(char(WhichTot_dem));
    Net_Dem(i,1)=Data.(Abb{index}).(char(WhichNet_dem));
    BType{i,1}=Data.(char(Abb{index})).Building_Type;
    
    hold on
    if Data.(char(Abb{index})).Building_Type == 'CA'
        plot(Age(i),Total_Dem(i),'or')
    elseif Data.(char(Abb{index})).Building_Type == 'H'
        plot(Age(i),Total_Dem(i),'og')
    elseif Data.(char(Abb{index})).Building_Type == 'RL'
        plot(Age(i),Total_Dem(i),'ok')
    elseif Data.(char(Abb{index})).Building_Type == 'OA'
        plot(Age(i),Total_Dem(i),'oc')
    else
        plot(Age(i),Total_Dem(i),'om')
    end
    
end
xlabel('Date of Construction')
ylabel('Total Demand(gal)')
if title_toggle==0
    title('Tot Demand vs Age of Buildings at UT Austin')
else
end
h = zeros(3, 1);
h(1) = scatter(NaN,NaN,marker_size,'oc','filled','MarkerEdgeColor','k');
h(2) = scatter(NaN,NaN,marker_size,'or','filled','MarkerEdgeColor','k');
h(3) = scatter(NaN,NaN,marker_size,'ok','filled','MarkerEdgeColor','k');
h(4) = scatter(NaN,NaN,marker_size,'og','filled','MarkerEdgeColor','k');
h(5) = scatter(NaN,NaN,marker_size,'om','filled','MarkerEdgeColor','k');
legend(h, 'OA','CA','RL','H','PA','Location','northwest');
legend boxoff  
hold off

%% Building Age vs. Net Demand 
figure
for i=1:length(filenames)
    index = find(strcmp(FN, filenames{i}));
    Sequential_Abb(i,1)=Abb(index);
    GSFi(i,1)=Data.(Abb{index}).('GSF');
    Age(i,1)=Data.(Abb{index}).('Date_of_Construction');
    WUI_AVG_Total(i,1)=Data.(Abb{index}).(char(WhichWUI_avg));
    Total_Dem(i,1)=Data.(Abb{index}).(char(WhichTot_dem));
    Net_Dem(i,1)=Data.(Abb{index}).(char(WhichNet_dem));
    BType{i,1}=Data.(char(Abb{index})).Building_Type;
    
    hold on
    if Data.(char(Abb{index})).Building_Type == 'CA'
        scatter(Age(i),Net_Dem(i),marker_size,'or','filled','MarkerEdgeColor','k')
    elseif Data.(char(Abb{index})).Building_Type == 'H'
        scatter(Age(i),Net_Dem(i),marker_size,'og','filled','MarkerEdgeColor','k')
    elseif Data.(char(Abb{index})).Building_Type == 'RL'
        scatter(Age(i),Net_Dem(i),marker_size,'ok','filled','MarkerEdgeColor','k')
    elseif Data.(char(Abb{index})).Building_Type == 'OA'
        scatter(Age(i),Net_Dem(i),marker_size,'oc','filled','MarkerEdgeColor','k')
    else
        scatter(Age(i),Net_Dem(i),marker_size,'om','filled','MarkerEdgeColor','k')
    end
    
end
xlabel('Date of Construction')
ylabel('Net Demand(gal/ft^2)')
if title_toggle==0
    title('Net Demand vs Age of Buildings at UT Austin')
else
end
h = zeros(3, 1);
h(1) = scatter(NaN,NaN,marker_size,'oc','filled','MarkerEdgeColor','k');
h(2) = scatter(NaN,NaN,marker_size,'or','filled','MarkerEdgeColor','k');
h(3) = scatter(NaN,NaN,marker_size,'ok','filled','MarkerEdgeColor','k');
h(4) = scatter(NaN,NaN,marker_size,'og','filled','MarkerEdgeColor','k');
h(5) = scatter(NaN,NaN,marker_size,'om','filled','MarkerEdgeColor','k');
legend(h, 'OA','CA','RL','H','PA','Location','northwest');
legend boxoff  
hold off

%% Study-Wide Top 10 WUI Bar Chart
figure
hold on
x0=10;
y0=10;
width=750;
height=300;
set(gcf,'units','points','position',[x0,y0,width,height])
[sortedHeights, sortIndices]=sort(WUI_AVG_Total, 'descend');
sortedX = Sequential_Abb(sortIndices, :);
sortedx_B_type = BType(sortIndices, :);
sortedX=sortedX(1:10,:);
sortedHeights=sortedHeights(1:10,:);
sortedx_B_type = sortedx_B_type(1:10,:);
for i=1:length(sortedHeights)
h=bar(i,sortedHeights(i));
if sortedx_B_type{i}=='CA'
    set(h,'FaceColor','r')
elseif sortedx_B_type{i}=='OA'
    set(h,'FaceColor','c')
elseif sortedx_B_type{i}=='H'
    set(h,'FaceColor','g')
elseif sortedx_B_type{i}=='PA'
    set(h,'FaceColor','m')
else %sortedx_B_type(i)=='RL'
    set(h,'FaceColor','k')
end
end
set(gca,'xtick',1:length(sortedX),'XTickLabel',sortedX,'XTickLabelRotation',270)
xlabel('Building Abbreviation')
ylabel('Average WUI (gal/ft2)')
if title_toggle==0
    title('Comparative WUI for Top 10 Consumers')
else
end
h = zeros(3, 1);
h(1) = scatter(NaN,NaN,marker_size,'sc','filled','MarkerEdgeColor','k');
h(2) = scatter(NaN,NaN,marker_size,'sr','filled','MarkerEdgeColor','k');
h(3) = scatter(NaN,NaN,marker_size,'sk','filled','MarkerEdgeColor','k');
h(4) = scatter(NaN,NaN,marker_size,'sg','filled','MarkerEdgeColor','k');
h(5) = scatter(NaN,NaN,marker_size,'sm','filled','MarkerEdgeColor','k');
legend(h, 'OA','CA','RL','H','PA','Location','northeast');
legend boxoff
hold off


%% Study-Wide WUI Bar Chart
figure
hold on
x0=10;
y0=10;
width=1000;
height=400;
set(gcf,'units','points','position',[x0,y0,width,height])
[sortedHeights, sortIndices]=sort(WUI_AVG_Total, 'descend');
sortedX = Sequential_Abb(sortIndices, :);
sortedx_B_type = BType(sortIndices, :);
for y=1:length(sortedHeights)
h=bar(y,sortedHeights(y));
if sortedx_B_type{y}=='CA'
    set(h,'FaceColor','r')
elseif sortedx_B_type{y}=='OA'
    set(h,'FaceColor','c')
elseif sortedx_B_type{y}=='H'
    set(h,'FaceColor','g')
elseif sortedx_B_type{y}=='PA'
    set(h,'FaceColor','m')
else %sortedx_B_type(y)=='RL'
    set(h,'FaceColor','k')
end
end
set(gca,'xtick',1:length(sortedX),'XTickLabel',sortedX,'XTickLabelRotation',270)
xlabel('Building Abbreviation')
ylabel('Average WUI (gal/ft2)')
if title_toggle==0
    title('Comparative WUI')
else
end
h = zeros(3, 1);
h(1) = scatter(NaN,NaN,marker_size,'sc','filled','MarkerEdgeColor','k');
h(2) = scatter(NaN,NaN,marker_size,'sr','filled','MarkerEdgeColor','k');
h(3) = scatter(NaN,NaN,marker_size,'sk','filled','MarkerEdgeColor','k');
h(4) = scatter(NaN,NaN,marker_size,'sg','filled','MarkerEdgeColor','k');
h(5) = scatter(NaN,NaN,marker_size,'sm','filled','MarkerEdgeColor','k');
legend(h, 'OA','CA','RL','H','PA','Location','northeast');
legend boxoff
hold off


%% Weekly Demand Profiles
if length(filenames)==length(filenames_master) && time_of_interest ==1
length_week=8;
CA_week=zeros(length(filenames_CA),length_week);
H_week=zeros(length(filenames_H),length_week);
OA_week=zeros(length(filenames_OA),length_week);
PA_week=zeros(length(filenames_PA),length_week);
RL_week=zeros(length(filenames_RL),length_week);

Master_Week=[CA_week;H_week;RL_week;OA_week;PA_week];

clear max
clear min
for i=1:length(filenames)
    index = find(strcmp(FN, filenames{i}));
    Sequential_Abb(i,1)=Abb(index);
    [DayNumber,DayName] = weekday(Data.(char(Abb{index})).(char(WhichDateTime)));
    d=datenum(Data.(char(Abb{index})).(char(WhichDateTime)));
    d1=datenum(daily_date_range{1});
    d2=datenum(daily_date_range{2});
    idx=d>d1& d<d2;
    DayName=DayName(idx);
    DayName=cellstr(DayName);
    high=max(Data.(Abb{index}).(char(WhichWUI))(idx));
    low=min(Data.(Abb{index}).(char(WhichWUI))(idx));
    Week_Profile=((Data.(Abb{index}).(char(WhichWUI))(idx)))-low;
    
    if Data.(char(Abb{index})).Building_Type == 'CA'
        Master_Week(i,:)=Week_Profile./(high-low);
    elseif Data.(char(Abb{index})).Building_Type == 'H'
        Master_Week(i,:)=Week_Profile./(high-low);
    elseif Data.(char(Abb{index})).Building_Type == 'RL'
        Master_Week(i,:)=Week_Profile./(high-low);
    elseif Data.(char(Abb{index})).Building_Type == 'OA'
        Master_Week(i,:)=Week_Profile./(high-low);
    else
        Master_Week(i,:)=Week_Profile./(high-low);
    end
end
% Master_Week=[CA_week;H_week;RL_week;OA_week;PA_week];

a=length(filenames_CA);
b=length(filenames_H);
c=length(filenames_RL);
d=length(filenames_OA);
e=length(filenames_PA);
CA_week=Master_Week(1:a,1:length_week);
H_week=Master_Week(a+1:a+b,1:length_week);
RL_week=Master_Week(a+b+1:a+b+c,1:length_week);
OA_week=Master_Week(a+b+c+1:a+b+c+d,1:length_week);
PA_week=Master_Week(a+b+c+d+1:a+b+c+d+e,1:length_week);

figure
hold on
for i= 1:size(CA_week,1)
plot(CA_week(i,:),'r')
end
set(gca,'xticklabel',DayName')
xTick=get(gca,'xtick');
xMax=max(xTick);
xMin=min(xTick);
newXTick=linspace(xMin,xMax,length(DayName));
set(gca,'xTick',1:length(DayName));
xlabel('Day of the Week')
ylabel('Normalized Water Demand')
if title_toggle==0
    title('Normalized Weekly CA Profiles')
else
end
hold off

figure
hold on
for i= 1:size(H_week,1)
plot(H_week(i,:),'g')
end
set(gca,'xticklabel',DayName')
xTick=get(gca,'xtick');
xMax=max(xTick);
xMin=min(xTick);
newXTick=linspace(xMin,xMax,length(DayName));
set(gca,'xTick',1:length(DayName));
xlabel('Day of the Week')
ylabel('Normalized Water Demand')
if title_toggle==0
    title('Normalized Weekly H Profiles')
else
end
hold off

figure
hold on
for i= 1:size(RL_week,1)
plot(RL_week(i,:),'k')
end
set(gca,'xticklabel',DayName')
xTick=get(gca,'xtick');
xMax=max(xTick);
xMin=min(xTick);
newXTick=linspace(xMin,xMax,length(DayName));
set(gca,'xTick',1:length(DayName));
xlabel('Day of the Week')
ylabel('Normalized Water Demand')
if title_toggle==0
    title('Normalized Weekly RL Profiles')
else
end
hold off

figure
hold on
for i= 1:size(OA_week,1)
plot(OA_week(i,:),'c')
end
set(gca,'xticklabel',DayName')
xTick=get(gca,'xtick');
xMax=max(xTick);
xMin=min(xTick);
newXTick=linspace(xMin,xMax,length(DayName));
set(gca,'xTick',1:length(DayName));
xlabel('Day of the Week')
ylabel('Normalized Water Demand')
if title_toggle==0
    title('Normalized Weekly OA Profiles')
else
end
hold off

figure
hold on
for i= 1:size(PA_week,1)
plot(PA_week(i,:),'m')
end
set(gca,'xticklabel',DayName')
xTick=get(gca,'xtick');
xMax=max(xTick);
xMin=min(xTick);
newXTick=linspace(xMin,xMax,length(DayName));
set(gca,'xTick',1:length(DayName));
xlabel('Day of the Week')
ylabel('Normalized Water Demand')
if title_toggle==0
    title('Normalized Weekly PA Profiles')
else
end
hold off
else
end

%% Example of Data Structure
Data
Data.(char(Abb{index}))

save('Data.mat')

cd C:\Users\Michael\Documents\Research\Water\Main_Code\Master_Code

save('Data.mat')
close all
