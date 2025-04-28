# NAME:		transformation_toolbox
# ONELINER:	convert the motion info between different tools (BIS, VC, and MONAI)
# NOTE:     'ITKreader' and 'NibabelReader' in LoadImaged has the same orientation
# EXAMPLE:  /data16/private/jz729/project/DL_HMC/dl-hmc/notebooks/Transformation_Testing_AO101.ipynb
# AUTHOR:	Jiazhen Zhang
# CREATED:	2023-07-20

import numpy as np
from scipy.spatial.transform import Rotation as R
from numpy.linalg import inv

# ----------------------------------------------------------------------- 
#    INPUT    : 1. BIS output matr (4x4)
#               2. voxel size from images used for generating BIS matr
#               3. dimension from images used for generating BIS matr
#    OUTPUT   : MOLAR Vicra file matrix format (4x4)
# ----------------------------------------------------------------------- 
def BIS_to_VC(input_matrix,resl_pix,resl_dim):
    ref_pix = resl_pix
    ref_dim = resl_dim

    # Scale and flip resl
    scale_and_flip_resl = np.diag([resl_pix[0], -resl_pix[1], resl_pix[2], 1])
    scale_and_flip_resl[1, 3] = (resl_dim[0] - 1) * resl_pix[0]

    # Flip and inverse scale ref
    flip_and_inv_scale_ref = np.diag([1 / ref_pix[0], -1 / ref_pix[1], 1 / ref_pix[2], 1])
    flip_and_inv_scale_ref[1, 3] = ref_dim[0] - 1

    # Compute STM
    STM = flip_and_inv_scale_ref @ np.linalg.inv(input_matrix) @ scale_and_flip_resl
    
    # Compute fix_mat
    # 1. Change the origin by fliping and moving
    # 2. Scale using voxel size
    fix_mat = np.array([[1 / resl_pix[0], 0., 0., (resl_dim[0] - 1) / 2],
                        [0., -1 / resl_pix[1], 0., (resl_dim[1] - 1) / 2],
                        [0., 0., -1 / resl_pix[2], (resl_dim[2] - 1) / 2],
                        [0., 0., 0., 1.]])
    
    inv_mat = np.linalg.inv(fix_mat)
    VC_matrix = inv_mat @ STM @ fix_mat
    
    return VC_matrix


# ----------------------------------------------------------------------- 
#    INPUT    : 1. MOLAR Vicra file matrix format (4x4) 
#               2. voxel size from images used for generating BIS matr
#               3. dimension from images used for generating BIS matr
#    OUTPUT   : BIS output matr (4x4)
# ----------------------------------------------------------------------- 
def VC_to_BIS(input_matrix,resl_pix,resl_dim):
    ref_pix = resl_pix
    ref_dim = resl_dim
    
    # Compute fix_mat
    # 1. Change the origin by fliping and moving
    # 2. Scale using voxel size
    fix_mat = np.array([[1 / resl_pix[0], 0., 0., (resl_dim[0] - 1) / 2],
                        [0., -1 / resl_pix[1], 0., (resl_dim[1] - 1) / 2],
                        [0., 0., -1 / resl_pix[2], (resl_dim[2] - 1) / 2],
                        [0., 0., 0., 1.]])
    
    inv_mat = np.linalg.inv(fix_mat)
    
    STM = fix_mat @ input_matrix @ inv_mat
    
    # Scale and flip resl
    scale_and_flip_resl = np.diag([resl_pix[0], -resl_pix[1], resl_pix[2], 1])
    scale_and_flip_resl[1, 3] = (resl_dim[0] - 1) * resl_pix[0]

    # Flip and inverse scale ref
    flip_and_inv_scale_ref = np.diag([1 / ref_pix[0], -1 / ref_pix[1], 1 / ref_pix[2], 1])
    flip_and_inv_scale_ref[1, 3] = ref_dim[0] - 1

    # Compute STM
    inv_BIS_matrix = scale_and_flip_resl @ STM @ flip_and_inv_scale_ref
    BIS_matrix = np.linalg.inv(inv_BIS_matrix)
    
    return BIS_matrix


# ----------------------------------------------------------------------- 
#    INPUT    : 1. BIS output matr (4x4) 
#               2. voxel size from images used for generating BIS matr
#               3. dimension from images used for generating BIS matr
#    OUTPUT   : MONAI affine matrix (4x4)
# ----------------------------------------------------------------------- 
def BIS_to_MONAI(input_matrix,resl_pix,resl_dim):
    ref_pix = resl_pix
    ref_dim = resl_dim
    
    # 1. BIS to STM
    # scale
    scale_up = np.diag([resl_pix[0], resl_pix[1], resl_pix[2], 1])
    scale_down = np.linalg.inv(scale_up)
    
    # calculate STM
    STM =  scale_down @ input_matrix @ scale_up  

    
    # 2. STM to MONAI
    # shift
    shift  = np.array([[1. ,  0.,  0., (resl_dim[0] - 1)/2],
                       [0. ,  1.,  0., (resl_dim[1] - 1)/2],
                       [0. ,  0.,  1., (resl_dim[2] - 1)/2],
                       [0. ,  0.,  0., 1.                 ]])
    inv_shift = np.linalg.inv(shift)
    # flip2
    flip2  = np.array([[-1. ,  0.,  0., (resl_dim[0] - 1)],
                       [ 0. , -1.,  0., (resl_dim[1] - 1)],
                       [ 0. ,  0.,  1., 0.               ],
                       [ 0. ,  0.,  0., 1.               ]])
    inv_flip2 = np.linalg.inv(flip2)
    
    # calculate monai_matrix
    monai_matrix = inv_shift @ inv_flip2 @ STM @ flip2 @ shift
    
    return monai_matrix


# ----------------------------------------------------------------------- 
#    INPUT    : 1. MONAI affine matrix (4x4) 
#               2. voxel size from images used for generating BIS matr
#               3. dimension from images used for generating BIS matr
#    OUTPUT   : BIS output matr (4x4)
# ----------------------------------------------------------------------- 
def MONAI_to_BIS(input_matrix,resl_pix,resl_dim):
    ref_pix = resl_pix
    ref_dim = resl_dim
    
    # shift
    shift  = np.array([[1. ,  0.,  0., (resl_dim[0] - 1)/2],
                       [0. ,  1.,  0., (resl_dim[1] - 1)/2],
                       [0. ,  0.,  1., (resl_dim[2] - 1)/2],
                       [0. ,  0.,  0., 1.                 ]])
    inv_shift = np.linalg.inv(shift)
    # flip2
    flip2  = np.array([[-1. ,  0.,  0., (resl_dim[0] - 1)],
                       [ 0. , -1.,  0., (resl_dim[1] - 1)],
                       [ 0. ,  0.,  1., 0.               ],
                       [ 0. ,  0.,  0., 1.               ]])
    inv_flip2 = np.linalg.inv(flip2)
    
    # calculate monai_matrix
    STM = flip2 @ shift @ input_matrix @ inv_shift @ inv_flip2
    
    # scale
    scale_up = np.diag([resl_pix[0], resl_pix[1], resl_pix[2], 1])
    scale_down = np.linalg.inv(scale_up)
    
    BIS_matrix =  scale_up @ STM @ scale_down  
    
    return BIS_matrix


# ----------------------------------------------------------------------- 
#    INPUT    : 1. MOLAR Vicra file matrix format (4x4) 
#               2. voxel size from images used for generating BIS matr
#               3. dimension from images used for generating BIS matr
#    OUTPUT   : MONAI affine matrix (4x4) 
# ----------------------------------------------------------------------- 
def VC_to_MONAI(input_matrix,resl_pix,resl_dim):
	tmp_bis_matrix = VC_to_BIS(input_matrix,resl_pix,resl_dim)
	monai_matrix = BIS_to_MONAI(tmp_bis_matrix,resl_pix,resl_dim)
	return monai_matrix


# ----------------------------------------------------------------------- 
#    INPUT    : 1. MONAI affine matrix (4x4) 
#               2. voxel size from images used for generating BIS matr
#               3. dimension from images used for generating BIS matr
#    OUTPUT   : MOLAR Vicra file matrix format (4x4) 
# ----------------------------------------------------------------------- 
def MONAI_to_VC(input_matrix,resl_pix,resl_dim):
	tmp_bis_matrix = MONAI_to_BIS(input_matrix,resl_pix,resl_dim)
	VC_matrix = BIS_to_VC(tmp_bis_matrix,resl_pix,resl_dim)
	return VC_matrix


# ----------------------------------------------------------------------- 
# **NOTE #1: METHOD 1**
#    One line : Rotation/Translation to Decomposed 6 elements

#    INPUT    : 12 Vicra elements (Vicra position 2-13)
#    Order    : R11,R12,R13,T14,R21,R22,R23,T24,R31,R32,R33,T34

#    OUTPUT   : Decomposed 6 parameters 
#    Order    : Tx,Ty,Tz,Rx,Ry,Rz

# **NOTE #2: METHOD 2**
#    One line : Decomposed 6 elements to Rotation/Translation

#    INPUT    : Decomposed 6 parameters 
#    Order    : Tx,Ty,Tz,Rx,Ry,Rz

#    OUTPUT   : 12 Vicra elements (Vicra position 2-13) 
#    Order    : R11,R12,R13,T14,R21,R22,R23,T24,R31,R32,R33,T34
# ----------------------------------------------------------------------- 

def RotTransMatrix_6Params(Input_elements, Method):
    if Method == 1:
        decomposed_transMatrix = np.zeros((6))
        decomposed_transMatrix[0] = Input_elements[3]
        decomposed_transMatrix[1] = Input_elements[7]
        decomposed_transMatrix[2] = Input_elements[11]
        
        Rot_Mat = R.from_matrix([
            [Input_elements[0], Input_elements[1], Input_elements[2]],
            [Input_elements[4], Input_elements[5], Input_elements[6]],
            [Input_elements[8], Input_elements[9], Input_elements[10]]
        ])
        eul = Rot_Mat.as_euler('XYZ', degrees=True)

        decomposed_transMatrix[3] = eul[0]
        decomposed_transMatrix[4] = eul[1]
        decomposed_transMatrix[5] = eul[2]
        
        Output = decomposed_transMatrix
        return Output
    
    elif Method == 2:
        degrees_xyz = Input_elements[3:6]
        eul = R.from_euler('XYZ',degrees_xyz, degrees=True)
        rotation_matrix_from_decomposed = eul.as_matrix()
        
        one = rotation_matrix_from_decomposed[0][0]
        two = rotation_matrix_from_decomposed[0][1]
        three = rotation_matrix_from_decomposed[0][2]
        four = Input_elements[0]
        five =rotation_matrix_from_decomposed[1][0]
        six = rotation_matrix_from_decomposed[1][1]
        seven = rotation_matrix_from_decomposed[1][2]
        eight = Input_elements[1]
        nine = rotation_matrix_from_decomposed[2][0]
        ten = rotation_matrix_from_decomposed[2][1]
        eleven = rotation_matrix_from_decomposed[2][2]
        twelve = Input_elements[2]

        Output = np.array([one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve])
        return Output
        
    else:
        Output = [];
        print('Input method is not recognized in this function. Please choose 1 or 2.')
        print('1 = Rotation/Translation to 6 elements')
        print('2 = 6 elements to Rotation/Translation')
        return Output


# ----------------------------------------------------------------------- 
#    INPUT    : Decomposed 6 parameters (Tx,Ty,Tz,Rx,Ry,Rz)
#    OUTPUT   : Affine matrix (4x4) 
# ----------------------------------------------------------------------- 
def six_to_fourbyfour(six_params):
	T_line = RotTransMatrix_6Params(six_params,2)
	T_matrix = np.reshape(T_line,(3,4))
	T_matrix = np.insert(T_matrix, 3, np.array([0., 0., 0., 1.]), axis=0)

	return T_matrix

# ----------------------------------------------------------------------- 
#    INPUT    : Affine matrix (4x4) 
#    OUTPUT   : Decomposed 6 parameters (Tx,Ty,Tz,Rx,Ry,Rz)
# ----------------------------------------------------------------------- 
def fourbyfour_to_six(T_matrix):
	T_line = np.reshape(T_matrix, 16)[0:12]
	six_params = RotTransMatrix_6Params(T_line,1)

	return six_params