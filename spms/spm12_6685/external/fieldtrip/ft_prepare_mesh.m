function [bnd, cfg] = ft_prepare_mesh(cfg, mri)

% FT_PREPARE_MESH creates a triangulated surface mesh for the volume
% conduction model. The mesh can either be selected manually from raw
% mri data or can be generated starting from a segmented volume
% information stored in the mri structure. The result is a bnd
% structure which contains the information about all segmented surfaces
% related to mri and are expressed in world coordinates.
%
% Use as
%   bnd = ft_prepare_mesh(cfg, mri)
%   bnd = ft_prepare_mesh(cfg, seg)
%
% Configuration options:
%   cfg.method      = string, can be 'interactive', 'projectmesh', 'iso2mesh', 'isosurface',
%                     'headshape', 'hexahedral', 'tetrahedral'
%   cfg.tissue      = cell-array with tissue types or numeric vector with integer values
%   cfg.numvertices = numeric vector, should have same number of elements as cfg.tissue
%   cfg.downsample  = integer number (default = 1, i.e. no downsampling), see FT_VOLUMEDOWNSAMPLE
%   cfg.headshape   = (optional) a filename containing headshape, a Nx3 matrix with surface
%                     points, or a structure with a single or multiple boundaries
%
% To facilitate data-handling and distributed computing you can use
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure.
%
% Example
%   mri             = ft_read_mri('Subject01.mri');
%
%   cfg             = [];
%   cfg.output      = {'scalp', 'skull', 'brain'};
%   segmentation    = ft_volumesegment(cfg, mri);
%
%   cfg             = [];
%   cfg.tissue      = {'scalp', 'skull', 'brain'};
%   cfg.numvertices = [800, 1600, 2400];
%   bnd             = ft_prepare_mesh(cfg, segmentation);
%
% See also FT_VOLUMESEGMENT, FT_PREPARE_HEADMODEL, FT_PLOT_MESH

% Undocumented functionality: at this moment it allows for either
%   bnd = ft_prepare_mesh(cfg)             or
%   bnd = ft_prepare_mesh(cfg, headmodel)
% but more consistent would be to specify a volume conduction model with
%   cfg.headmodel     = structure with volume conduction model, see FT_PREPARE_HEADMODEL
%   cfg.headshape     = name of file containing the volume conduction model, see FT_READ_VOL
%
% Undocumented options, I have no clue why they exist
%   cfg.method = {'singlesphere' 'concentricspheres' 'localspheres'}

% Copyrights (C) 2009-2012, Robert Oostenveld & Cristiano Micheli
% Copyrights (C) 2012-2013, Robert Oostenveld & Lilla Magyari
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_prepare_mesh.m 10765 2015-10-09 18:10:47Z roboos $

revision = '$Id: ft_prepare_mesh.m 10765 2015-10-09 18:10:47Z roboos $';

% do the general setup of the function
ft_defaults
ft_preamble init
ft_preamble debug
ft_preamble loadvar mri
ft_preamble provenance mri
ft_preamble trackconfig

% the abort variable is set to true or false in ft_preamble_init
if abort
  return
end

% we cannot use nargin, because the data might have been loaded from cfg.inputfile
hasdata = exist('mri', 'var');

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'forbidden', {'numcompartments', 'outputfile', 'sourceunits', 'mriunits'});

% get the options
cfg.downsample  = ft_getopt(cfg, 'downsample', 1); % default is no downsampling
cfg.numvertices = ft_getopt(cfg, 'numvertices');   % no default

% This was changed on 3 December 2013, this backward compatibility can be removed in 6 months from now.
if isfield(cfg, 'interactive')
  if strcmp(cfg.interactive, 'yes')
    warning('please specify cfg.method=''interactive'' instead of cfg.interactive=''yes''');
    cfg.method = 'interactive';
  end
  cfg = rmfield(cfg, 'interactive');
end

% This was changed on 3 December 2013, it makes sense to keep it like this on the
% long term (previously there was no explicit use of cfg.method, now there is).
% Translate the input options in the appropriate cfg.method.
if ~isfield(cfg, 'method')
  if isfield(cfg, 'headshape') && ~isempty(cfg.headshape)
    warning('please specify cfg.method=''headshape''');
    cfg.method = 'headshape';
  elseif hasdata && ~strcmp(ft_voltype(mri), 'unknown')
    % the input is a spherical volume conduction model
    cfg.method = ft_voltype(mri);
  elseif hasdata
    warning('please specify cfg.method=''projectmesh'', ''iso2mesh'' or ''isosurface''');
    warning('using ''projectmesh'' as default');
    cfg.method = 'projectmesh';
  end
end

if hasdata && cfg.downsample~=1
  % optionally downsample the anatomical volume and/or tissue segmentations
  tmpcfg = keepfields(cfg, {'downsample'});
  mri = ft_volumedownsample(tmpcfg, mri);
  [cfg, mri] = rollback_provenance(cfg, mri);
end

switch cfg.method
  case 'interactive'
    % this makes sense with a non-segmented MRI as input
    % call the corresponding helper function
    bnd = prepare_mesh_manual(cfg, mri);
    
  case {'projectmesh', 'iso2mesh', 'isosurface'}
    % this makes sense with a segmented MRI as input
    % call the corresponding helper function
    bnd = prepare_mesh_segmentation(cfg, mri);
    
  case 'headshape'
    % call the corresponding helper function
    bnd = prepare_mesh_headshape(cfg);
    
  case 'hexahedral'
    % the MRI is assumed to contain a segmentation
    % call the corresponding helper function
    bnd = prepare_mesh_hexahedral(cfg, mri);
    
  case 'tetrahedral'
    % the MRI is assumed to contain a segmentation
    % call the corresponding helper function
    bnd = prepare_mesh_tetrahedral(cfg, mri);
    
  case {'singlesphere' 'concentricspheres' 'localspheres'}
    % FIXME for localspheres it should be replaced by an outline of the head, see private/headsurface
    fprintf('triangulating the sphere in the volume conductor\n');
    [pnt, tri] = makesphere(cfg.numvertices);
    bnd = [];
    mri = ft_convert_units(mri);      % ensure that it has units
    headmodel = ft_datatype_headmodel(mri); % rename it and ensure that it is consistent and up-to-date
    for i=1:length(headmodel.r)
      bnd(i).pnt(:,1) = pnt(:,1)*headmodel.r(i) + headmodel.o(1);
      bnd(i).pnt(:,2) = pnt(:,2)*headmodel.r(i) + headmodel.o(2);
      bnd(i).pnt(:,3) = pnt(:,3)*headmodel.r(i) + headmodel.o(3);
      bnd(i).tri = tri;
    end
    
  otherwise
    error('unsupported cfg.method')
end

% copy the geometrical units from the input to the output
if ~isfield(bnd, 'unit') && hasdata && isfield(mri, 'unit')
  for i=1:numel(bnd)
    bnd(i).unit = mri.unit;
  end
elseif ~isfield(bnd, 'unit')
  bnd = ft_convert_units(bnd);
end

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble previous   mri
ft_postamble provenance bnd
ft_postamble history    bnd

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HELPER FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pnt, tri] = makesphere(numvertices)

if isempty(numvertices)
  [pnt,tri] = icosahedron162;
  fprintf('using the mesh specified by icosaedron162\n');
elseif numvertices==42
  [pnt,tri] = icosahedron42;
  fprintf('using the mesh specified by icosaedron%d\n',size(pnt,1));
elseif numvertices==162
  [pnt,tri] = icosahedron162;
  fprintf('using the mesh specified by icosaedron%d\n',size(pnt,1));
elseif numvertices==642
  [pnt,tri] = icosahedron642;
  fprintf('using the mesh specified by icosaedron%d\n',size(pnt,1));
elseif numvertices==2562
  [pnt,tri] = icosahedron2562;
  fprintf('using the mesh specified by icosaedron%d\n',size(pnt,1));
else
  [pnt, tri] = msphere(numvertices);
  fprintf('using the mesh specified by msphere with %d vertices\n',size(pnt,1));
end
