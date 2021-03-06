function varargout = GrAnaEdge(varargin)
% functional connectivity analysis (edges)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GrAnaEdge_OpeningFcn, ...
                   'gui_OutputFcn',  @GrAnaEdge_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function GrAnaEdge_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% get input (command line options)
handles.ana = varargin{1};
handles.leg = varargin{2};
disp('<GrAnaEdges> : Starting tool for connectivity analysis.');

% check if analyses are compatible
NumAna = size(handles.ana,2);
if NumAna~=2 | handles.ana{1}{1}.Ana{1}.Configure.ROI.Num~=handles.ana{2}{1}.Ana{1}.Configure.ROI.Num
   disp('<GrAnaEdges> : Analyses not compatible!');
   return;
end

handles.NumNodes = size(handles.ana{1}{1}.Ana{1}.Matrix,1);
handles.Names    = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names;
handles.TheAna   = 1;

NumAna1 = size(handles.ana{1},2);
NumAna2 = size(handles.ana{2},2);
set(handles.editgroupA,'String',sprintf('group/condition A: %s %d',handles.leg{1},NumAna1));
set(handles.editgroupB,'String',sprintf('group/condition B: %s %d',handles.leg{2},NumAna2));

result = RetrieveCorrelationCoefficients(handles);
handles.Amean       = result.Amean;
handles.Astd        = result.Astd;
handles.Aweights    = result.Aweights;   % (row: edge, column: subject)
handles.Bmean       = result.Bmean; 
handles.Bstd        = result.Bstd;
handles.Bweights    = result.Bweights;   % (row: edge, column: subject)
handles.indexNode1  = result.indexNode1;
handles.indexNode2  = result.indexNode2;
handles.NumEdges    = result.NumEdges;

clear result;
NumBoot = str2num(get(handles.editnumbootstraptests,'String'));
result  = PerformStatisticalTests(handles.Aweights,handles.Bweights,NumBoot,1);
handles.Prob             = result.Prob;
handles.Prob_ttest2      = result.Prob_ttest2;

% configure popupmenus
list{1}='two-sample two-sided t-test'; 
list{2}='paired t-test';
list{3}='two-sample permutation test';
list{4}='two-sample one-sided +';
list{5}='two-sample one-sided -';
set(handles.popupmenustattest,'String',list);
Names = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names;
set(handles.popupmenuselectseedregion,'String',Names);

% plot
handles.counter = Plot(handles);

guidata(hObject, handles);
assignin('base','handles',handles);


function varargout = GrAnaEdge_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function editprobcut_Callback(hObject, eventdata, handles)
handles.counter = Plot(handles);
guidata(hObject, handles);
function editprobcut_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editnumsigedges_Callback(hObject, eventdata, handles)
function editnumsigedges_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenustattest_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editgroupA_Callback(hObject, eventdata, handles)
function editgroupA_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editgroupB_Callback(hObject, eventdata, handles)
function editgroupB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editnumbootstraptests_Callback(hObject, eventdata, handles)
function editnumbootstraptests_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFDR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenuselectseedregion_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popupmenustattest_Callback(hObject, eventdata, handles)
NumBoot  = str2num(get(handles.editnumbootstraptests,'String'));
StatTest = get(hObject,'Value');
result   = PerformStatisticalTests(handles.Aweights,handles.Bweights,NumBoot,StatTest);
assignin('base','ABweights',[handles.Aweights',handles.Bweights']);
ez.pprint('ABweights per subject/row exported. Each weight/column represents the correlation between two ROI beta series.');
handles.Prob        = result.Prob;
handles.Prob_ttest2 = result.Prob_ttest2;
% plot
guidata(hObject, handles);
handles.counter = Plot(handles);

function pushbuttoncorrelationcoefficients_Callback(hObject, eventdata, handles)
% plot correlation coefficients
% ProbCut = str2double(get(handles.editprobcut,'String'));
% disp(sprintf('Probability threshold: %f',ProbCut));
% counter    = 0;
% wincounter = 0;
% SEED   = get(handles.checkboxseedbasedanalysis,'Value');
% seednr = get(handles.popupmenuselectseedregion,'Value');
% for i=1:handles.NumEdges,
%       if SEED 
%           if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
%              continue;
%           end
%       end
%       theprob = handles.Prob(i);   
%       if theprob<=ProbCut
%          if mod(counter,9)==0
%            figure('Name',sprintf('Distribution of correlation coefficients'));
%            wincounter = 0;
%          end
%          counter = counter +1;
%          wincounter = wincounter+1;
%          subplot(3,3,wincounter);
%          hist(handles.Aweights(i,:),[-1:0.1:1]);
%          hold on;
%          hist(handles.Bweights(i,:),[-1:0.1:1]);
%          h = findobj(gca,'Type','patch');
%          set(h(2),'FaceColor','w','EdgeColor','b','facealpha',0.75,'LineWidth',2);
%          set(h(1),'FaceColor','w','EdgeColor','r','facealpha',0.75,'LineWidth',2,'LineStyle','-.');
%          title(sprintf('%s and %s (p=%f)',handles.Names{handles.indexNode1(i)},handles.Names{handles.indexNode2(i)},theprob));
%          xlabel('correlation coefficients');
%          ylabel('number of subjects');
%          legend({handles.leg{1},handles.leg{2}},'Interpreter', 'none');
%       end
% end % end loop over edges


ProbCut = str2double(get(handles.editprobcut,'String'));
counter    = 0;
wincounter = 0;
SEED   = get(handles.checkboxseedbasedanalysis,'Value');
seednr = get(handles.popupmenuselectseedregion,'Value');
for i=1:handles.NumEdges,
      if SEED 
          if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
             continue;
          end
      end
      theprob = handles.Prob(i);   
      if theprob<=ProbCut
         if mod(counter,9)==0
           figure('Name',sprintf('Boxplot of correlation coefficients'));
           wincounter = 0;
         end
         counter = counter +1;
         wincounter = wincounter+1;
         sp = subplot(3,3,wincounter);
         % box plot individual scores
         edgeName = sprintf('%s <-> %s',handles.Names{handles.indexNode1(i)},handles.Names{handles.indexNode2(i)});
         boxplot([handles.Aweights(i,:)',handles.Bweights(i,:)'],'Labels',{handles.leg{1},handles.leg{2}},'Whisker',1,'Jitter',1);
         title(edgeName);
         m = [handles.Aweights(i,:)',handles.Bweights(i,:)'];
         e = eps(max(m(:)));
         h = flipud(findobj(sp,'tag','Outliers')); % flip order of handles
         for jj = 1 : length( h )
            x =  get( h(jj), 'XData' );
            y =  get( h(jj), 'YData' );
            for ii = 1 : length( x )
                if not( isnan( x(ii) ) )
                    ix = find( abs( m(:,jj)-y(ii) ) < e );
                    text( x(ii), y(ii), sprintf( '  s%d', ix ) )
                end
            end
         end
      end
end % end loop over edges

%
% Seed based analysis
%
function checkboxseedbasedanalysis_Callback(hObject, eventdata, handles)
SEED   = get(handles.checkboxseedbasedanalysis,'Value');
seednr = get(handles.popupmenuselectseedregion,'Value');
if SEED==true
    handles.Prob_seed = [];
    handles.Prob_ttest2_seed = [];
    k=0;
    for i=1:handles.NumEdges,
         if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
             continue;
         end
         k=k+1;
         handles.Prob_seed(k)             = handles.Prob(i);
         handles.Prob_ttest2_seed(k)      = handles.Prob_ttest2(i);   
    end
end
guidata(hObject, handles);
Plot(handles);

% --- Select seed-region
function popupmenuselectseedregion_Callback(hObject, eventdata, handles)
SEED     = get(handles.checkboxseedbasedanalysis,'Value');
seednr   = get(handles.popupmenuselectseedregion,'Value');
StatTest = get(handles.popupmenustattest,'Value');
StatStr  = get(handles.popupmenustattest,'String');
if SEED==false
   return; 
end
handles.Prob_seed = [];
handles.Prob_ttest2_seed = [];
k=0;
for i=1:handles.NumEdges
     if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
         continue;
     end
     k=k+1;
     handles.Prob_seed(k)             = handles.Prob(i);
     handles.Prob_ttest2_seed(k)      = handles.Prob_ttest2(i); 
end
guidata(hObject, handles);
Plot(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function counter = Plot(handles)
StatTest = get(handles.popupmenustattest,'Value');
StatStr  = get(handles.popupmenustattest,'String');
ProbCut = str2double(get(handles.editprobcut,'String'));
fprintf('Probability threshold: %f \n',ProbCut);
% seed-based analysis?
SEED   = get(handles.checkboxseedbasedanalysis,'Value');
seednr = get(handles.popupmenuselectseedregion,'Value');
if SEED 
    fprintf('Seed region: %d \n',seednr);
end
counter = 0;
for i=1:handles.NumEdges
      if SEED 
          if handles.indexNode1(i)~=seednr & handles.indexNode2(i)~=seednr
             continue;
          end
      end
      theprob = handles.Prob(i);
      if theprob<=ProbCut
         counter = counter +1;
         strn1 = strtrim(handles.Names{handles.indexNode1(i)});
         strn2 = strtrim(handles.Names{handles.indexNode2(i)});
         n1max = ez.len(strn1);
         n2max = ez.len(strn2);
%          if n1max>20
%              n1max=20;
%          end
%          if n2max>20
%              n2max=20;
%          end        
         Edgenames(counter)   = cellstr(sprintf('%s <-> %s',strn1(1:n1max),strn2(1:n2max)));
         if StatTest==2

           tableData(counter,1) = handles.Prob(i);
           tableData(counter,2) = handles.Amean(i);
           tableData(counter,3) = handles.Bmean(i);
         else
           tableData(counter,1) = handles.Prob_ttest2(i);
           tableData(counter,2) = handles.Prob(i);
           tableData(counter,3) = handles.Amean(i);
           tableData(counter,4) = handles.Bmean(i); 
         end
      end
end

% display table with edges which are significantly different
if counter>0
  set(handles.tableedges,'RowName',cell(Edgenames));

  if get(handles.popupmenustattest,'Value')==2
      columnHeaders = {StatStr{StatTest},handles.leg{1},handles.leg{2}}; 
  else
      columnHeaders = {'two-sample two-sided t-test',StatStr{StatTest},handles.leg{1},handles.leg{2}};
  end
  
  set(handles.tableedges,'ColumnName',columnHeaders);
  set(handles.tableedges,'data',tableData);
else
  Edgenames(1)   = cellstr('no edge below threshold');
  
  set(handles.tableedges,'RowName',cell(Edgenames));
  if get(handles.popupmenustattest,'Value')==2
    columnHeaders = {StatStr{StatTest},handles.leg{1},handles.leg{2}}; 
    tableData(1,1) = 0;
    tableData(1,2) = 0;
    tableData(1,3) = 0;
  else
    columnHeaders = {'two-sample two-sided t-test',StatStr{StatTest},handles.leg{1},handles.leg{2}};       
    tableData(1,1) = 0;
    tableData(1,2) = 0;
    tableData(1,3) = 0;
    tableData(1,4) = 0; 
  end
    set(handles.tableedges,'ColumnName',columnHeaders);
  set(handles.tableedges,'data',tableData);  
end

if SEED==false
   set(handles.editnumsigedges,'String',sprintf('Number of significant edges: %d (of %d, fraction: %f, expected: %.1f)',counter,handles.NumEdges,counter/handles.NumEdges,ProbCut*handles.NumEdges));
end
if SEED==true
   set(handles.editnumsigedges,'String',sprintf('Number of significant edges: %d (of %d, fraction: %f, expected: %.1f)',counter,handles.NumNodes-1,counter/(handles.NumNodes-1),ProbCut*(handles.NumNodes-1)));
end

% plot probability
figure(handles.figure1);
subplot(1,1,1,'Parent',handles.uipanelprob);
if SEED==false
    if StatTest==2 % paired t-test
      hold off;
      hist(handles.Prob,[0:0.02:1]);  

    else
      hold off;
      hist(handles.Prob,[0:0.02:1]);
      hold on;
      hist(handles.Prob_ttest2,[0:0.02:1]);
    end
    Nentr=ez.len(handles.Prob);
end
if SEED==true
   if StatTest==2 % paired t-test   
     hold off;
     hist(handles.Prob_seed,[0:0.02:1]);   

   else    
     hold off;  
     hist(handles.Prob_seed,[0:0.02:1]);
     hold on;
     hist(handles.Prob_ttest2_seed,[0:0.02:1]);
   end
   Nentr=ez.len(handles.Prob_seed);
end

if get(handles.popupmenustattest,'Value')==2 
  title('p distribution');
  ylabel('number of edges');
  xlabel('probability');
else
  h = findobj(gca,'Type','patch');
  set(h(2),'FaceColor','w','EdgeColor','b','facealpha',0.75,'LineWidth',2);
  set(h(1),'FaceColor','w','EdgeColor','r','facealpha',0.75,'LineWidth',2,'LineStyle','-.');  
  title(sprintf('p distribution group differences (A vs B) (%d)',Nentr));
  ylabel('number of edges');
  xlabel('probability');
  legend({StatStr{StatTest},'two-sample two-sided t-test'},'Interpreter', 'none');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function results = RetrieveCorrelationCoefficients(handles)
disp('<GrAnaEdges::RetrieveCorrelationCoefficients> : Retrieving correlation coefficients ...');
tic
N      = handles.NumNodes;
theind = find(triu(ones(N,N),1));
results.NumEdges = ez.len(theind);
[ results.indexNode1 results.indexNode2 ] = ind2sub(N,theind);
disp(sprintf('<GrAnaEdges::RetrieveCorrelationCoefficients> : Nodes %d ----- Edges %d (symmetric matrix)',N,results.NumEdges));
[results.Amean results.Astd results.Aweights] = MeanCorrCoef(handles.ana{1},theind);
[results.Bmean results.Bstd results.Bweights] = MeanCorrCoef(handles.ana{2},theind); 
toc
disp('<GrAnaEdges::RetrieveCorrelationCoefficients> : ... done.');

function [themean, thestd, edgeweights] = MeanCorrCoef(anaobj,theind)
% edgeweights(edge,subject)
NumSubj = size(anaobj,2);
edgeweights = zeros(ez.len(theind),NumSubj); % correlation coefficients for different jobs
size(edgeweights);
for idx=1:NumSubj % loop over jobs
    try
      edgeweights(:,idx) = anaobj{idx}.Ana{1}.Matrix(theind)';  
    catch
        fprintf('Wrong number of edges. Subject: %d \n',idx);
        size(anaobj{idx}.Ana{1}.Matrix)
    end
end
themean = mean(edgeweights');
thestd  = std(edgeweights');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function results = PerformStatisticalTests(Amat,Bmat,Num,StatTest)
% input: matrix (rows: edges, columns: subjects)
ez.pprint('=============================================================');
tic
disp('<GrAnaEdges::PerformStatisticalTests> : Performing two-tailed two-sample t-test assuming unequal variance...');
Prob_ttest2              = mattest(Amat,Bmat); % two-tailed two-sample t-test assuming unequal variance, call ttest2(X1, X2, [],[],'unequal',2)
results.Prob_ttest2      = Prob_ttest2';
results.Prob             = Prob_ttest2';
if StatTest==2 % paired t-test
    disp('<GrAnaEdges::PerformStatisticalTests> : Performing paired t-test ...');
    if size(Amat,2)==size(Bmat,2)
        for iedge=1:size(Amat,1)
            [htmp, Prob_pairedttest(iedge)]= ttest(Amat(iedge,:),Bmat(iedge,:));
        end
    else
        disp('<GrAnaEdges::PerformStatisticalTests> : Error. Different number of subjects! Bailing out!');
        return;
    end
    results.Prob = Prob_pairedttest;
end
if StatTest==3 % permutation two-sample t test
     fprintf('<GrAnaEdges::PerformStatisticalTests> : Performing two-sample permutation test. Number of permutations: %d \n',Num);
     Prob_perm    = mattest(Amat,Bmat,'Permute',Num); % permutation test
     results.Prob = Prob_perm';
end
if StatTest==4 % one-sided test
    disp('<GrAnaEdges::PerformStatisticalTests> : two-sample t-test  - tail right');
    [h, Prob_right] = ttest2(Amat',Bmat',[],'right');
    results.Prob     = Prob_right';
end
if StatTest==5 % one-sided test
    disp('<GrAnaEdges::PerformStatisticalTests> : two-sample t-test  - tail left');
    [h, Prob_left] = ttest2(Amat',Bmat',[],'left');
    results.Prob    = Prob_left';
end
toc
disp('<GrAnaEdges::PerformStatisticalTests> : ... done');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% p-value adjustment using FDR/ Bonferroni FWE                      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton_FDR_Callback(hObject, eventdata, handles)
storey = ez.Inputs({'Storey (1) or BH (2)?'},{'1'},'FDR Option'); % z-threshold for outlier rejection
if strcmp(storey,'1'), storey=true; else storey=false; end

qcut  = str2double(get(handles.editFDR,'String'));
SEED  = get(handles.checkboxseedbasedanalysis,'Value');
if SEED==true
    p = handles.Prob_seed;
    fprintf('Analysis restricted to single seed region. Number of statistical tests: %d \n',ez.len(p));
else
    p = handles.Prob; 
    fprintf('Number of statistical tests: %d \n',ez.len(p));
end

if storey
    
    disp('FDR correction (Storey, 2002; as implemented in MATLAB mafdr-function).');
    figure('Name','MAFDR-Storey');
    [fdr, q] = mafdr(p,'showplot',true);
    padj     = max(p(find(q<=qcut)));
    fprintf('Adjusted p-value: %f.  \n',padj);
else
    
    disp('Method for FDR correction: Benjamini and Hochberg, 1995');
    figure('Name','MAFDR-BH');
    mafdr_fdr   = mafdr(p,'BHFDR',true,'showplot',true);
    significant = mafdr_fdr<=qcut;
    padj        = max(p(find(mafdr_fdr<=qcut)));
    fprintf('=====>> FDR correction: q < %f \n',qcut);
    if ez.len(padj)==0
        disp('No node survived FDR correction.');
        % return;
    else
        fprintf('Adjusted p-threshold (MAFDR): %f \n',padj);
    end
end

set(handles.editprobcut,'String',num2str(padj));
guidata(hObject, handles);
Plot(handles);

function pushbutton_fwe_Callback(hObject, eventdata, handles)

disp('Bonferroni FWE correction.');
q     = str2double(get(handles.editFDR,'String'));
SEED  = get(handles.checkboxseedbasedanalysis,'Value');
if SEED==true
    p = handles.Prob_seed;
    fprintf('Analysis restricted to single seed region. Number of statistical tests: %d \n',ez.len(p));
else
    p = handles.Prob; 
    fprintf('Number of statistical tests: %d \n',ez.len(p));
end
padj  = q/ez.len(p);
set(handles.editprobcut,'String',num2str(padj));
guidata(hObject, handles);
Plot(handles);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Visualization NW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function pushbuttonplot_Callback(hObject, eventdata, handles)
if ~isfield(handles.ana{1}{1}.Ana{1}.Configure.ROI,'ROICOM')
    
    disp('Calculating center.of.mass. of nodes ...');
    ROIS      = handles.ana{1}{1}.Ana{1}.Configure.ROI.File;
    NumROIs   = handles.ana{1}{1}.Ana{1}.Configure.ROI.Num;
    % get c.o.m.
    for iroi=1:size(ROIS,1)
        load(strtrim(ROIS{iroi}));
        compos(:,iroi) = c_o_m(roi);
    end
    % short labels of ROIs
    for iroi=1:NumROIs
        % shortname = '';
        % roiname   = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names{iroi};
        % theidx   = findstr(roiname,'_');
        % shortname(1)=roiname(1);
        % if ez.len(theidx)<3
        %     shortname(2)=roiname(2);
        %     shortname(3)=roiname(3);
        % end
        % for idx=theidx
        %     shortname(ez.len(shortname)+1) = roiname(idx+1);
        % end
        % shortlabel{iroi} = shortname;
        % fprintf('%s -> %s \n',roiname,shortname);

        % autoshortening is weird. do not use. simply copy over
        shortlabel{iroi} = handles.ana{1}{1}.Ana{1}.Configure.ROI.Names{iroi};
    end
    
    handles.ana{1}{1}.Ana{1}.Configure.ROI.ROIFILES      = ROIS;
    handles.ana{1}{1}.Ana{1}.Configure.ROI.ROICOM        = compos;
    handles.ana{1}{1}.Ana{1}.Configure.ROI.ROIShortLabel = shortlabel;
end

compos     = handles.ana{1}{1}.Ana{1}.Configure.ROI.ROICOM;
shortlabel = handles.ana{1}{1}.Ana{1}.Configure.ROI.ROIShortLabel;
disp('Creating connectivity matrix (.node and .edge files) ...');
rownames      = get(handles.tableedges,'RowName');
columnnames   = get(handles.tableedges,'ColumnName');
thedata       = get(handles.tableedges,'data');
handles.Names = strtrim(handles.Names);
numrows       = ez.len(rownames);
for irow=1:numrows
    htemp{irow} = textscan(rownames{irow},'%s <-> %s');
    idx1(irow)  = find(strcmp(handles.Names,char(htemp{irow}{1}))==1);
    idx2(irow)  = find(strcmp(handles.Names,char(htemp{irow}{2}))==1);
end
idx = unique([idx1 idx2]);
numnodes = ez.len(idx);
for inodes=1:numnodes
    disp(handles.Names{idx(inodes)});
end
fprintf('Number of nodes: %d \n',numnodes);

fprintf('Will save edge/node file for each condition/group and for their difference in the comparison; if you do not want to save, you can cancel and continue.\n');
% generate edge/node file for each condition/group in the comparison but do
% not display automatically (user can display the files with brainnet
% viewer by themselves
% here we go
% 1:
nwmatrix = zeros(numnodes,numnodes);
for irow=1:numrows
    weight_diff = thedata(irow,end-1);
    nwmatrix(find(idx==idx1(irow)),find(idx==idx2(irow)))=weight_diff;
    nwmatrix(find(idx==idx2(irow)),find(idx==idx1(irow)))=weight_diff;
end
basename = [handles.leg{1}];
[edgeFile,nodeFile] = basco_CreateNodeEdgeFiles(idx,compos,shortlabel,nwmatrix,basename);
% 2:
nwmatrix = zeros(numnodes,numnodes);
for irow=1:numrows
    weight_diff = thedata(irow,end);
    nwmatrix(find(idx==idx1(irow)),find(idx==idx2(irow)))=weight_diff;
    nwmatrix(find(idx==idx2(irow)),find(idx==idx1(irow)))=weight_diff;
end
basename = [handles.leg{2}];
[edgeFile,nodeFile] = basco_CreateNodeEdgeFiles(idx,compos,shortlabel,nwmatrix,basename);
%%%%%%%% done

nwmatrix = zeros(numnodes,numnodes);
for irow=1:numrows
    weight_diff = thedata(irow,end-1) - thedata(irow,end);
    fprintf('%d <-> %d : weight(left-right)=%f \n',find(idx==idx1(irow)),find(idx==idx2(irow)),weight_diff);
    nwmatrix(find(idx==idx1(irow)),find(idx==idx2(irow)))=weight_diff;
    nwmatrix(find(idx==idx2(irow)),find(idx==idx1(irow)))=weight_diff;
end
basename = [handles.leg{1} '-' handles.leg{2}];
[edgeFile,nodeFile] = basco_CreateNodeEdgeFiles(idx,compos,shortlabel,nwmatrix,basename);
if ~isempty(edgeFile)
disp('Plotting NW ...')
% fastBrainNetPlot(idx,compos,nwmatrix,shortlabel);
bnDir = fileparts(which('BrainNet'));
meshFile = fullfile(bnDir,'Data','SurfTemplate','BrainMesh_ICBM152.nv');
spmDir = fileparts(which('spm'));
% volFile = fullfile(spmDir,'canonical','single_subj_T1.nii');
cfgFile = fullfile(bnDir,'SelfBrainNetCfg.mat');
BrainNet_MapCfg(meshFile,edgeFile,nodeFile,cfgFile);
disp('... done.')


end

function pushbuttonviewrois_Callback(hObject, eventdata, handles)
% display marsbar ROIs
rownames      = get(handles.tableedges,'RowName');
columnnames   = get(handles.tableedges,'ColumnName');
thedata       = get(handles.tableedges,'data');
handles.Names = strtrim(handles.Names);
numrows       = ez.len(rownames);
for irow=1:numrows
    htemp{irow} = textscan(rownames{irow},'%s <-> %s');
    idx1(irow)  = find(strcmp(handles.Names,char(htemp{irow}{1}))==1);
    idx2(irow)  = find(strcmp(handles.Names,char(htemp{irow}{2}))==1);
end
idx = unique([idx1 idx2]);
% show ROIs
ROIS      = handles.ana{1}{1}.Ana{1}.Configure.ROI.File;
NumROIs   = handles.ana{1}{1}.Ana{1}.Configure.ROI.Num;
selection = zeros(1,NumROIs);
selection(idx) = 1;
DisplayMarsBarROIs(ROIS,selection);

function pushbuttonprinttable_Callback(hObject, eventdata, handles)
% print table

rownames = get(handles.tableedges,'RowName');
thedata  = get(handles.tableedges,'data');
numrows  = ez.len(rownames);

% save the table to a file
savData = num2cell(thedata);
savData = cellfun(@(e) sprintf('%.2f',e), savData(:,:), 'UniformOutput',false);
savData = [rownames,savData];
ez.cell2csv('edge_analysis_results.csv',savData);
% done

for irow=1:numrows
    htemp{irow} = textscan(rownames{irow},'%s <-> %s');
    roi1 = char(htemp{irow}{1});
    roi2 = char(htemp{irow}{2});
    roi1 = strrep(roi1,'_',' ');
    roi2 = strrep(roi2,'_',' ');
    stdroi1 = '                    ';
    stdroi2 = '                    ';
    stdroi1(1:ez.len(roi1)) = roi1;
    stdroi2(1:ez.len(roi2)) = roi2;
    col=size(thedata,2);
    xthedata = arrayfun(@(e) sprintf('%.2f\t',e), thedata(irow,:), 'UniformOutput',false);
    xthedata = [xthedata{:}];
    fprintf('%s %s %s \n',stdroi1,stdroi2,xthedata); 
end
fprintf('The data has also been save to edge_analysis_results.csv in pwd.\n');

function edit_corrpval_Callback(hObject, eventdata, handles)
function edit_corrpval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_corrtype_Callback(hObject, eventdata, handles)
function popupmenu_corrtype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu_corrtail_Callback(hObject, eventdata, handles)
function popupmenu_corrtail_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
