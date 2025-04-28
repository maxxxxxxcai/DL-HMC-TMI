clc;clear;

fn_vc1 = '..\python\test_data\test_vc1.vc';
fn_vc2 = '..\python\test_data\test_vc2.vc';

output_matr = Relative_motion_A_to_B(fn_vc1,fn_vc2);


vc_1 = dlmread(fn_vc1);
vc_2 = dlmread(fn_vc2);

[MOLAR_VC_matrix_full,VC_6_params] = DL_HMC_concat_VC(vc_1(2:13), vc_2(2:13));

disp('');