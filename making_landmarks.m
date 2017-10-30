function making_landmarks()

clear;
close;
clc;

db_dir = 'E:\12_CV_Research\hospital_pain\data\VID_splitted\';
%input_directory = ['E:\12_CV_Research\hospital_pain\data\VID_splitted\' subdir];
out_dir = 'E:\12_CV_Research\hospital_pain\data\landmarks_determined\';

mkdir(out_dir);

users = dir(db_dir);
users = {users(3:end).name};

for fol =11%:length(users)
    vid_dir = fullfile(out_dir,users{fol});
    mkdir(vid_dir)
    
    vids=dir(fullfile(db_dir,users{fol}));
    vids={vids(3:end).name};
    for v = 21:length(vids)
        frmin_dir = fullfile(db_dir,users{fol},vids{v});
        frmout_dir = fullfile(out_dir,users{fol},vids{v});
        mkdir(frmout_dir);

        imageList = dir(fullfile(frmin_dir,'*.jpg'));
        %imageList = dir(strcat(frmin_dir,'*.jpg'));


        if exist([frmout_dir '\' 'ptList.mat'], 'file')
            load([frmout_dir '\' 'ptList.mat']);
        else
            ptList = cell(length(imageList),1);
        end
        imgIndex = 1:10:length(imageList);
        %ptList = cell(length(imageList),1);
        %
        for  idx = 1:length(imgIndex)

            imgNo = imgIndex(idx);
            im_sample = imread([frmin_dir '\' imageList(imgNo).name]);

            if imgNo > 1
                ptList(imgIndex(idx-1)+1:imgNo) = ptList(imgIndex(idx-1)); %no.11 has same ptlist as 1-10
                imshow(im_sample);
%                 im_show = draw_cross(im_sample, ptList{imgNo}(:,1), ptList{imgNo}(:,2));
%                 imshow(im_show);
            else
                imshow(im_sample);  %first frm
            end

            %[x,y] = ginput(3);
            pt_eye_mouth_centers = ginput(9);



            %centroid = mean([x,y]);
            if size(pt_eye_mouth_centers,1) < 9
                if imgNo == 1
                    assert(0);
                end
                x =  ptList{imgNo-1}(:,1);
                y =  ptList{imgNo-1}(:,2);
            else
                x = pt_eye_mouth_centers(:,1);
                y = pt_eye_mouth_centers(:,2);
            end
            im_show = draw_cross(im_sample, x, y);
            imshow(im_show);
            %     figure;
            %     imshow(im_sample);

            ptList{imgNo} = [x y];

            close all;
        end

        %deal with the last 10 frms
        
        if imgIndex(end) == length(imageList) 
            ptList(imgIndex(end-1)+1:length(imageList)) = ptList(imgIndex(end-1));
            save([frmout_dir '\' 'ptList.mat'], 'ptList', '-v7.3');
        else
            ptList(imgIndex(end)+1:length(imageList)) = ptList(imgIndex(end));
            save([frmout_dir '\' 'ptList.mat'], 'ptList', '-v7.3');
        end

        %ptList(imgIndex(idx-1):imgNo) = ptList(imgIndex(idx-1));
%         ptList(imgIndex(end-1)+1:length(imageList)) = ptList(imgIndex(end-1)); %consider imgIndex(end) is the last frm
%         save([frmout_dir 'ptList.mat'], 'ptList', '-v7.3');

        %}
        clear ptList
        load([frmout_dir '\' 'ptList.mat']);
        %ptList(181:200) = ptList(180);

%         ptList(imgIndex(end-1)+1:length(imageList)) = ptList(imgIndex(end-1));
%         save([frmout_dir 'ptList.mat'], 'ptList', '-v7.3');

        outputVideo = VideoWriter(fullfile(frmout_dir, 'landmarks.avi'));
        outputVideo.FrameRate = 25; %shuttleVideo.FrameRate;
        open(outputVideo)
        registedImgList = zeros(280, 256, 3, length(imageList), 'uint8');
%crop
        for imgNo = 1:1:length(imageList);

            disp([num2str(imgNo) '/' num2str(length(imageList))])
            im_sample = imread([frmin_dir '\' imageList(imgNo).name]);
            x =  ptList{imgNo}(:,1);
            y =  ptList{imgNo}(:,2);

            template = [57 92; 73 78; 73 96; 98 88; 156 86; 182 76; 180 94; 197 92; 128 122];
            %template = [72 82; 184 82; 128 138];
            %centroid_template = round(mean(template));
            %offset_template = round(template - repmat(mean(template), [3 1]));

            tform = cp2tform([x y], template, 'nonreflective similarity'); %similarity %affine
            im_sample_registered = imtransform(im_sample, tform, 'bicubic', 'XData', [1 256], 'YData', [1 280], 'XYScale', 1);

            %imshow(im_sample_registered);
            im_show = draw_cross(im_sample_registered, template(:,1), template(:,2));
            imshow(im_show);
            writeVideo(outputVideo,im_show);

            imwrite(im_sample_registered, [frmout_dir '\' imageList(imgNo).name], 'jpg');
            registedImgList(:,:,:,imgNo) = imread([frmout_dir '\' imageList(imgNo).name]);

        end
        average_image = mean(double(registedImgList), 4); %average over all img
        average_image = uint8(round(average_image));
        imshow(average_image)
        save([frmout_dir '\' 'registed_video.mat'], 'registedImgList', 'average_image', '-v7.3');
        close(outputVideo);
        imshow(round(average_image));
    end
end
end

function im_show = draw_cross(im_show, x, y)

off = 15;
x = round(x);
y = round(y);

for i = 1:length(x)
    im_show(y(i), x(i)-off:x(i)+off,1)=255;
    im_show(y(i), x(i)-off:x(i)+off,2)=0;
    im_show(y(i), x(i)-off:x(i)+off,3)=0;
    
    im_show(y(i)-off:y(i)+off, x(i),1)=255;
    im_show(y(i)-off:y(i)+off, x(i),2)=0;
    im_show(y(i)-off:y(i)+off, x(i),3)=0;
    
end
end