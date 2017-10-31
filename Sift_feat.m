clear,clc

db_dir='E:\12_CV_Research\hospital_pain\data\saveFaceVid_gray\';
out_dir='E:\12_CV_Research\hospital_pain\SIFT_features_gray\'; 
out_dir_orig = 'E:\12_CV_Research\hospital_pain\SIFT_features_gray_nomean\';

mkdir(out_dir)  

binSize = 8;
magnif = 3;


users = dir(db_dir);
users = {users(3:end).name};
[ux_orig, ux, ux_per] = deal([]);
for fol = 1:length(users)
    mkdir(fullfile(out_dir, users{fol}))
    mkdir(fullfile(out_dir_orig, users{fol}))
    vids = dir(fullfile(db_dir, users{fol}));
    vids = {vids(3:end).name};
    idx = 1;
    for v = 1:length(vids)
        load(fullfile(db_dir, users{fol}, vids{v}))
        frmNo = size(faceVid, 3);
        indexFrm(v) = frmNo;
        for frm = 1:frmNo
            Img = faceVid(:,:,frm);
            %Img = vl_impattern('Img');
            %image(Img);
            Img = single(Img);
            Is = vl_imsmooth(Img, sqrt((binSize/magnif)^2 - .25));
            [f, d] = vl_dsift(Is, 'size', binSize, 'floatDescriptors');
            ux_orig = [ux_orig;d];
            d_ = mean(d,2);
            ux(:,frm) = d_; 
            ux_per(:,idx) = d_; 
            idx = idx+1;
        end
        save(fullfile(out_dir_orig, users{fol}, vids{v}), 'ux_orig', 'f');
        save(fullfile(out_dir, users{fol}, vids{v}), 'ux', 'f');

        clear ux_orig ux
    end
    save([fullfile(out_dir, users{fol}) '\' 'Sift_per_person'], 'ux_per', 'indexFrm');
    
end

%             f(3,:) = binSize/magnif;
%             f(4,:) = 0;
%             [f_, d_] = vl_sift(Img, 'frames', f);
% 
%             %test the results of sift
%             perm = randperm(size(f, 2));
%             sel = perm(1:50);
%             h1 = vl_plotframe(f(:,sel));
%             h2 = vl_plotframe(f(:,sel));
%             set(h1, 'color', 'k', 'linewidth', 3);
%             set(h2, 'color', 'y', 'linewidth', 2);
%             h3 = vl_plotsiftdescriptor(d(:, sel), f(:,sel));
%             set(h3, 'color', 'g');
