function result = main(SPMPath, clusterPath, stat, folder)
% Input:
%       SPMPath: path to SPM.mat of 2nd level (not applicable to 1st-level SPM.mat)
%       clusterPath: path to cluster image(s), str or cell of str
%                    recommendated ClusterName format is: ClusterName_x_y_z_roi.mat
%       stat: method to summarize values across all voxels within a cluster, 'mean'(default), 'median', 'eigen1', 'wtmean' (weighted mean)
%       folder, path to folder where extracted betas (csv) will be saved , default pwd, if not exist, auto create the folder
% Output:
%       csv file with extracted betas
%       returns a cell representing the csv result
% Note:
%       Uses marsbar functions to extract
%       If marsbar path not in searchpath, auto add them internally first.
%       The result should be equal to right-click->extract data->raw y in SPM map
%           if very close, due possibly to conversion of marsbar cluster format

if (isempty(which('marsbar'))||isempty(which('spm_get')))
    ez.print('addpath marsbar...')
    extsPath = ez.joinpath(ez.parentdir(ez.parentdir(ez.csd())), 'extensions');
    thePath = ez.lsd(extsPath,'^marsbar');
    thePath = ez.joinpath(extsPath,thePath{1});
    addpath(thePath,'-end');
    % additional path that would be added by marsbar
    addpath(ez.joinpath(thePath,'spm5'),'-end');
end

if ischar(clusterPath), clusterPath = cellstr(clusterPath); end
if nargin<3, stat = 'mean'; end
if nargin<4, folder = pwd; else ez.mkdir(folder); end

header = cell(1,length(clusterPath));
result = [];
for i = 1:length(clusterPath)
    cluster = clusterPath{i};
    
    [~,clusterName] = ez.splitpath(cluster);
    header{1,i} = clusterName;
    
    % Make marsbar design object
    D  = mardo(SPMPath);
    % Make marsbar ROI object
    R  = maroi(cluster);
    % Fetch data into marsbar data object
    Y = get_marsy(R, D, stat);   % Y will be betas in the case of 2nd level SPM.mat, ignore the following part
    % get summary data from the Y object
    result = [result,summary_data(Y)];
    
    %     % Get contrasts from original design
    %     xCon = get_contrasts(D);
    %     % Estimate design on ROI data
    %     E = estimate(D, Y);
    %     % Put contrasts from original design back into design object
    %     E = set_contrasts(E, xCon);
    %     % get design betas
    %     b = betas(E);
    %     % get stats and stuff for all contrasts into statistics structure 
    %     marsS = compute_contrasts(E, 1:length(xCon));

end % end for
result = [header;num2cell(result)];
ez.cell2csv(fullfile(folder,'extracted_betas.csv'),result);

end % end function