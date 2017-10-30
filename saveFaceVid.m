clear,clc

db_dir='E:\Dropbox\landmarks_determined\';
out_dir='E:\12_CV_Research\hospital_pain\data\saveFaceVid_gray\';

mkdir(out_dir)

users = dir(db_dir);
users = {users(3:end).name};
tic
for fol = 1:length(users)
    mkdir(fullfile(out_dir,users{fol}))
    vids = dir(fullfile(db_dir, users{fol}));
    vids = {vids(3:end).name};
    
    for v = 1:length(vids)
        frmin_dir = fullfile(db_dir,users{fol},vids{v});
        %imageList = dir(fullfile(frmin_dir,'*.jpg'));
        load([fullfile(db_dir, users{fol},vids{v}) '\' 'registed_video.mat']);
        nfrms = size(registedImgList,4);
        faceVid=zeros(280, 256, nfrms, 'uint8');
%         registedImgList(:,:,:,imgNo) = imread([frmout_dir '\' imageList(imgNo).name]);
        for f = 1:nfrms
            %sample_img = imread([frmin_dir '\' imageList(f).name]);
            faceVid(:,:,f) = rgb2gray(registedImgList(:,:,:,f));
            %sample_img;
        end
        
        save(fullfile(out_dir,users{fol}, vids{v}),'faceVid') 
        %implay(faceVid)
        clear faceVid 
    end
end
toc