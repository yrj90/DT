clear
close all
addpath E:\12_CV_Research\hospital_pain\code\Fast_LBPTOP_Code
db_dir='E:\Dropbox\landmarks_determined\';
out_dir='E:\12_CV_Research\hospital_pain\LBPTOP_features\';

mkdir(out_dir)  

tic
% bloc=25;
% overlap=25;mode='nh';norm=0;           %nh->get a normalized histogram/means non-overlap
% tmp=[];
%----------Parameters------------%
% block size of (1x1x1), radius (R=1) and the number of neighbors (P=8)
R=1;
P=8;
patternMapping_u2 = getmapping(P,'u2');
nQr = 1;                   
nQc = 1; 
nQt = 1;         
rolr = 0;
colr = 0;
tolr = 0;   
allux = [];
%----------Parameters------------%

users=dir(db_dir);
users={users(3:end).name}; 
disp(pwd)
%idx = 1;
for fol = 1:length(users)
    mkdir(fullfile(out_dir,users{fol}))
    vids = dir(fullfile(db_dir, users{fol}));
    vids = {vids(3:end).name};
    indexVid(fol) = length(vids);
    for v = 1:length(vids)
        frmin_dir = fullfile(db_dir,users{fol},vids{v});
        %imageList = dir(fullfile(frmin_dir,'*.jpg'));
        load([frmin_dir '\' 'registed_video.mat']);
        data = registedImgList;
        [HIGO_xoy HIGO_xot HIGO_yot] = cal_cuboid_lbptop_vr(data, nQr, nQc, nQt, P, R, patternMapping_u2, rolr, colr, tolr);      
        ux(:,v) = [HIGO_xoy HIGO_xot HIGO_yot];
        %idx = idx+1;
        allux = [allux, ux];
    end
    save([fullfile(out_dir, users{fol}) '\' 'lbptop_p' int2str(P) '_r' int2str(R)], 'ux', 'vids');
    clear ux
end
save([out_dir 'ALL_lbptop_p' int2str(P) '_r' int2str(R)], 'allux', 'indexVid');

%----------randomly simulated 3-D video data------------%
data = randi([0,255],128,128,30);


tic
toc


