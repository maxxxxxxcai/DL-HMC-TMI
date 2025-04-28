%+
% NAME                   : DL_HMC_concat_VC.m
% ONELINER               : Update Vicra information
% LANGUAGE               : Matlab R2018b
%
% AUTHOR                 : E.Revilla
% CREATED                : 2020-07-10
%
% ARGUMENTS              : 
%   vc_1                 - [input]  1 line of VC, only the 12 elements
%   vc_2                 - [input]  1 line of VC, only the 12 elements
%   MOLAR_VC_matrix_full - [output] resulting transformation matrix
%   VC_6_params          - [output] resulting 6 parameters (translation and
%                                   rotation xyz)
%
% MODIFICATIONS          :
%   2020-07-10           - ecr33 - created
%   2020-07-22           - ecr33 - added the output MOLAR_VC_matrix_full
%
%-

function [MOLAR_VC_matrix_full,VC_6_params] = DL_HMC_concat_VC(vc_1,vc_2)

    VC_matrix1(1,1:3) = vc_1(1:3);
    VC_matrix1(1,4) = vc_1(4);
    VC_matrix1(2,1:3) = vc_1(5:7);
    VC_matrix1(2,4) = vc_1(8);
    VC_matrix1(3,1:3) = vc_1(9:11);
    VC_matrix1(3,4) = vc_1(12);
    VC_matrix1(4,1:4) = [0 0 0 1];
    
    VC_matrix2(1,1:3) = vc_2(1:3);
    VC_matrix2(1,4) = vc_2(4);
    VC_matrix2(2,1:3) = vc_2(5:7);
    VC_matrix2(2,4) = vc_2(8);
    VC_matrix2(3,1:3) = vc_2(9:11);
    VC_matrix2(3,4) = vc_2(12);
    VC_matrix2(4,1:4) = [0 0 0 1];
    
    BIS_new_timePeriod_each = (inv(VC_matrix1))*VC_matrix2;
    BIS_new_timePeriod_each_oneline = reshape(BIS_new_timePeriod_each',1,[]);
    MOLAR_VC_matrix = BIS_new_timePeriod_each_oneline(:,1:12);
    
    MOLAR_VC_matrix_full = [1,MOLAR_VC_matrix,0];
    
    decomposed_transMatrix(1,1) = MOLAR_VC_matrix_full(1,5); % X Translation
    decomposed_transMatrix(1,2) = MOLAR_VC_matrix_full(1,9); % Y Translation
    decomposed_transMatrix(1,3) = MOLAR_VC_matrix_full(1,13); % Z Translation
    decomposed_transMatrix(1,4) = atan2d(-MOLAR_VC_matrix_full(1,8),MOLAR_VC_matrix_full(1,12)); % X Rotation
    decomposed_transMatrix(1,5) = asind(MOLAR_VC_matrix_full(1,4)); % Y Rotation
    decomposed_transMatrix(1,6) = atan2d(-MOLAR_VC_matrix_full(1,3),MOLAR_VC_matrix_full(1,2)); % Z Rotation
    
    VC_6_params = decomposed_transMatrix;

end