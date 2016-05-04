% builds P#.img ROI parcels with #-mm cubes covering grey-matter areas
% 
% P2186.img: 10mm voxels => 2186 ROIs
% P1292.img: 12mm voxels => 1292 ROIs
% P830.img: 14mm voxels => 830 ROIs
% P576.img: 16mm voxels => 576 ROIs
% P406.img: 18mm voxels => 406 ROIs
% P304.img: 20mm voxels => 304 ROIs

a=spm_vol(fullfile(fileparts(which('spm')),'apriori','grey.nii'));
bbox=[-90 90; -126 90; -72 108];    % bounding box
THR=.10;                            % select ROIs where prob(grey matter)>THR
SideLengths=[10 12 14 16 18 20];    % length of ROI cube sides in mm 
nameroot='P';

for sidelength=SideLengths
    x0=[-fliplr(sidelength/2:sidelength:-bbox(1,1)) sidelength/2:sidelength:bbox(1,2)];
    y0=[-fliplr(sidelength/2:sidelength:-bbox(2,1)) sidelength/2:sidelength:bbox(2,2)];
    z0=[-fliplr(sidelength/2:sidelength:-bbox(3,1)) sidelength/2:sidelength:bbox(3,2)];
    x0=reshape(conn_bsxfun(@plus,x0,sidelength*(-4.5:4.5)'/10),1,[]);
    y0=reshape(conn_bsxfun(@plus,y0,sidelength*(-4.5:4.5)'/10),1,[]);
    z0=reshape(conn_bsxfun(@plus,z0,sidelength*(-4.5:4.5)'/10),1,[]);
    [x,y,z]=ndgrid(x0,y0,z0);
    xyz=[x(:) y(:) z(:) ones(numel(x),1)];
    tb=spm_get_data(a,pinv(a.mat)*xyz');
    tb=reshape(tb,size(x));
    tb=(tb(:,:,:)+tb(end:-1:1,:,:))/2; % forces symmetry
    mtb=permute(mean(mean(mean(reshape(tb,[10,size(tb,1)/10,10,size(tb,2)/10,10,size(tb,3)/10]),1),3),5),[2 4 6 1 3 5]);
    valid=mtb>THR;
    idx=find(valid);
    ROI=zeros(size(valid));
    [nill,sidx]=sort(mtb(idx));
    idx=idx(sidx);
    ROI(idx)=1:numel(idx);
    Nrois=numel(idx);
    x1=mean(reshape(x0,10,[]));
    y1=mean(reshape(y0,10,[]));
    z1=mean(reshape(z0,10,[]));
    mat=sidelength*eye(3);
    mat=[mat [x1(1);y1(1);z1(1)]-mat*[1;1;1]+1e-4; zeros(1,3) 1];
    mat(1,:)=-mat(1,:); ROI=ROI(end:-1:1,:,:);
    roi=struct('fname',[nameroot,num2str(Nrois),'.img'],'mat',mat,'dim',size(ROI),'pinfo',[1;0;0],'dt',[spm_type('uint16'),spm_platform('bigend')]);
    spm_write_vol(roi,ROI);
    fh=fopen([nameroot,num2str(Nrois),'.txt'],'wt');
    for n=1:max(ROI(:))
        [tx,ty,tz]=ind2sub(size(ROI),find(ROI==n));
        txyz=round(roi.mat*[tx ty tz 1]');
        fprintf(fh,'(%d %d %d)\n',txyz(1),txyz(2),txyz(3));
    end
    fclose(fh);
    fh=fopen([nameroot,num2str(Nrois),'.log'],'wt');
    for n=1:max(ROI(:))
        tidx=find(ROI==n);
        [tx,ty,tz]=ind2sub(size(ROI),tidx);
        txyz=round(roi.mat*[tx ty tz 1]');
        fprintf(fh,'ROI (%d %d %d): length = %dmm; probability gray matter = %.4f\n',txyz(1),txyz(2),txyz(3),sidelength,mtb(tidx));
    end
    fclose(fh);
    if 1 % resample to standard space
        [x,y,z]=ndgrid(1:a.dim(1),1:a.dim(2),1:a.dim(3));xyz=a.mat*[x(:) y(:) z(:) ones(numel(x),1)]';
        ROI=reshape(spm_get_data(roi,pinv(roi.mat)*xyz),a.dim);
        roi=struct('fname',[nameroot,num2str(Nrois),'.img'],'mat',a.mat,'dim',a.dim,'pinfo',[1;0;0],'dt',[spm_type('uint16'),spm_platform('bigend')]);
        spm_write_vol(roi,ROI);
    end
    fprintf('Created file %s. %dmm cubes. %d parcels\n',roi.fname,sidelength,numel(idx));
end
