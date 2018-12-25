clc
close all
clear all

img_list = dir('/home/yun/work/workspace/face_landmark_arr/img/*.jpg');
point_list = dir('/home/yun/work/workspace/face_landmark_arr/result/*.txt');
N = size(point_list,1);
cd '/home/yun/work/workspace'
mkdir 'Image-Warping'

for k = 1:N-1
  cd '/home/yun/work/workspace/Image-Warping'
  point_fn = strcat('/home/yun/work/workspace/face_landmark_arr/result/',point_list(1).name);
  dis_point_fn = strcat('/home/yun/work/workspace/face_landmark_arr/result/',point_list(k+1).name);

  
  f_pt = importdata(point_fn);
  dis_pt = importdata(dis_point_fn);

  fn= strcat('/home/yun/work/workspace/face_landmark_arr/img/',img_list(1).name);
  rgbimg = imread(fn);
  warpimg = rgbimg;
  if k == 1
    figure(k)
    imshow(rgbimg);
    title('Original Image')
  
    hold on

      S = size(f_pt,1);
      for i = 1:S
        plot(f_pt(i,1),f_pt(i,2),'go');
        %text(f_pt(i,1),f_pt(i,2), int2str(i), 'Color', 'r', 'fontsize', 15);
      end

      tri_pt = delaunay(f_pt)
      fid = fopen('triangle.txt','w');
      fprintf(fid,'%d %d %d\n',tri_pt.');
      fclose(fid);

      H = size(tri_pt,1);
      for jj = 1:H
          plot([f_pt(tri_pt(jj,1),1) f_pt(tri_pt(jj,2),1) f_pt(tri_pt(jj,3),1)], [f_pt(tri_pt(jj,1),2) f_pt(tri_pt(jj,2),2) f_pt(tri_pt(jj,3),2)], 'r');     
      end
  end

  lambda = zeros(3,1);
  for x = 0:256
      for y = 0:256
          v_p = [y; x; 1];
          
          for j = 1:H
           B = [dis_pt(tri_pt(j,1),2) dis_pt(tri_pt(j,1),1) 1; 
               dis_pt(tri_pt(j,2),2) dis_pt(tri_pt(j,2),1) 1; 
               dis_pt(tri_pt(j,3),2) dis_pt(tri_pt(j,3),1) 1]'; 
           
           A = [f_pt(tri_pt(j,1),2) f_pt(tri_pt(j,1),1) 1; 
               f_pt(tri_pt(j,2),2) f_pt(tri_pt(j,2),1) 1; 
               f_pt(tri_pt(j,3),2) f_pt(tri_pt(j,3),1) 1]';
                    
              lambda = B\v_p;
              if lambda(1)> 0 && lambda(2)> 0 && lambda(3)> 0
                  v = round(A * lambda);
                  warpimg(v(1),v(2),1:3) = rgbimg(y,x,1:3);
              end         
              
          end 
      end
  end

  %figure(k)
  %imshow(warpimg);
  %title('Warp Image')

  mkdir 'dis_img'
  cd '/home/yun/work/workspace/Image-Warping/dis_img'
  if k==1
    dis_fn = strcat('dis_img0.jpg');
    imwrite(rgbimg, dis_fn)
  end

  dis_fn = strcat('dis_img',int2str(k),'.jpg');
  imwrite(warpimg, dis_fn)
  hold on

  for i = 1:S
  plot(dis_pt(i,1),dis_pt(i,2),'go');
  %text(dis_pt(i,1),dis_pt(i,2), int2str(i), 'Color', 'r', 'fontsize', 25);
  end

  for jj = 1:H
      plot([dis_pt(tri_pt(jj,1),1) dis_pt(tri_pt(jj,2),1) dis_pt(tri_pt(jj,3),1)], [dis_pt(tri_pt(jj,1),2) dis_pt(tri_pt(jj,2),2) dis_pt(tri_pt(jj,3),2)], 'r');     
  end
end

dis_img_list = dir('/home/yun/work/workspace/Image-Warping/dis_img/*.jpg');
N = length(dis_img_list);

FileName = 'Face.gif';

for k = 1:N
    cd '/home/yun/work/workspace/Image-Warping/dis_img'
    fn= strcat('dis_img',int2str(k-1),'.jpg');
    RGB = imread(fn);
    imagesc(RGB);
    axis image
    [A,map] = rgb2ind(RGB,256);
    imagesc(A)
    colormap(map)
    axis image
    
    cd '/home/yun/work/workspace/Image-Warping'
    
    if k ==1
        imwrite(A,map,FileName,'gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(A,map,FileName,'gif','WriteMode','append','DelayTime',0.1);
    end
end

cd '/home/yun/work/workspace/Image-Warping/warping'


