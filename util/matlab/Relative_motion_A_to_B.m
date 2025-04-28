% A function to compute the relative motion between frame A and frame B.
% Assume you have vc for A to reference and vc for B to reference, we need
% a function to compute A to B, i.e., A is the new reference and B is the
% new moving.
%
% Example Input : 
%     Frame002 is your new REFERENCE  --> input VC1
%     Frame006 is your new MOVE FRAME --> input VC2
%
% Example Output:
%     One line VC format - relative motion from frame B to frame A
%
% NOTE:
% This function is similar to the following BIS command if you want to do
% the registration:
% 1. Convert output_matr --> BIS space 
%       (ex: jm100_20338_FDG_xform_006_to_002_try.matr)
% 2. Use the converted .matr to reslice 
%
% %BIS_VTK_DIR%\..\..\bin\vtk.exe
% %BIOIMAGESUITE%\bis_algorithm\bis_resliceimage.tcl --inp
% F:/MATLAB/Project/R21_Grant/test_pointA_to_pointB/jm100_20338_fdg-2-5mm_smoothed_002.nii
% --inp2
% F:/MATLAB/Project/R21_Grant/test_pointA_to_pointB/jm100_20338_fdg-2-5mm_smoothed_006.nii
% --inp3
% F:/MATLAB/Project/R21_Grant/test_pointA_to_pointB/jm100_20338_FDG_xform_006_to_002_try.matr
% --out jm100_20338_FDG_Reslice_006_to_002_try.img
%
% Here:
%  - jm100_20338_fdg-2-5mm_smoothed_002 (Reference).
%  - jm100_20338_FDG_Reslice_006_to_002_try.img (Resliced)
%  - these two should be aligned
%

function output_matr = Relative_motion_A_to_B(VC1,VC2)
    img_vc1 = dlmread(VC1);
    img_vc2 = dlmread(VC2);

    img_matr1 = [img_vc1(1,2),img_vc1(1,3),img_vc1(1,4),img_vc1(1,5);
        img_vc1(1,6),img_vc1(1,7),img_vc1(1,8),img_vc1(1,9);
        img_vc1(1,10),img_vc1(1,11),img_vc1(1,12),img_vc1(1,13);
        0,0,0,1];

    img_matr2 = [img_vc2(1,2),img_vc2(1,3),img_vc2(1,4),img_vc2(1,5);
        img_vc2(1,6),img_vc2(1,7),img_vc2(1,8),img_vc2(1,9);
        img_vc2(1,10),img_vc2(1,11),img_vc2(1,12),img_vc2(1,13);
        0,0,0,1];

    matr_move = (inv(img_matr1))*img_matr2;
    output_matr = [0,matr_move(1,1),matr_move(1,2),matr_move(1,3),...
    matr_move(1,4),matr_move(2,1),matr_move(2,2),matr_move(2,3),matr_move(2,4),...
    matr_move(3,1),matr_move(3,2),matr_move(3,3),matr_move(3,4),0.2];
end


