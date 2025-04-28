%+
% NAME              : RotTransMatrix_6Params.m
% ONELINER          : Perform conversion from Rotation/Translation to 
%                     6 decomposed  elements and vice versa
% LANGUAGE          : Matlab R2018b
%
% AUTHOR            : E.Revilla
%
% ARGUMENTS         :
%   Input_elements  - [input,num,required]
%                   - If method = 1, Input_elements should contain 12
%                     elements. Please look at Note #1 below for more
%                     information.
%                   - If method = 2, Input_elements should contain 6
%                     elements. Please look at Note #2 below for more
%                     information.
%   Method          - [input,num,required]
%                   - If method = 1, the function converts 
%                     Rotation/Translation to 6 elements
%                   - If method = 2, the function converts 
%                     6 elements to Rotation/Translation
%
% USAGE             :
% 
%       ---- Rotation/Translation to 6 elements ----
%       Input_elements = [0.994423	-0.104231	0.016097	0.006883
%        0.103476	0.993736	0.042212	12.938414	-0.020396	-0.040311
%       0.998979	5.866369]; 
%       SixElem = RotTransMatrix_6Params(Input_elements,1);
%
%        ---- 6 elements to Rotation/Translation ---- 
%       Input_elements = [0.006883 12.938414 5.866369 -2.41960194896131 
%       0.922329993035839 5.98364014668176];
%       TwelveElem = RotTransMatrix_6Params(Input_elements,2);
%
%
% ----------------------------------------------------------------------- %
% **NOTE #1: METHOD 1**
%    One liner: Rotation/Translation to 6 elements
%
%    INPUT    : Vicra elements (Vicra position 2-13)
%    Order    : R11,R12,R13,T14,R21,R22,R23,T24,R31,R32,R33,T34
%
%    OUTPUT   : Decomposed 6 parameters 
%    Order    : Tx,Ty,Tz,Rx,Ry,Rz
%
% **NOTE #2: METHOD 2**
%    One liner: 6 elements to Rotation/Translation
%
%    INPUT    : Decomposed 6 parameters 
%    Order    : Tx,Ty,Tz,Rx,Ry,Rz
%
%    OUTPUT   : Vicra elements (Vicra position 2-13) 
%    Order    : R11,R12,R13,T14,R21,R22,R23,T24,R31,R32,R33,T34
% ----------------------------------------------------------------------- %
%
%-

function Output = RotTransMatrix_6Params(Input_elements,Method)
    if Method == 1
        decomposed_transMatrix = zeros(1,6);

        decomposed_transMatrix(1,1) = Input_elements(1,4); % X Translation
        decomposed_transMatrix(1,2) = Input_elements(1,8); % Y Translation
        decomposed_transMatrix(1,3) = Input_elements(1,12); % Z Translation

        Rot_Mat = [Input_elements(1,1),Input_elements(1,2),Input_elements(1,3);...
            Input_elements(1,5),Input_elements(1,6),Input_elements(1,7);...
            Input_elements(1,9),Input_elements(1,10),Input_elements(1,11)];
        eul = rad2deg(func_rotm2eul(Rot_Mat));

        decomposed_transMatrix(1,4) = eul(1); % X Rotation
        decomposed_transMatrix(1,5) = eul(2); % Y Rotation
        decomposed_transMatrix(1,6) = eul(3); % Z Rotation

        Output = decomposed_transMatrix;
        
    elseif Method == 2
        radians_xyz = deg2rad(Input_elements(1,4:6));
        rotation_matrix_from_decomposed = func_eul2rotm2(radians_xyz);

        one = rotation_matrix_from_decomposed(1,1);
        two = rotation_matrix_from_decomposed(1,2);
        three = rotation_matrix_from_decomposed(1,3);
        four = Input_elements(1,1);
        five =rotation_matrix_from_decomposed(2,1);
        six = rotation_matrix_from_decomposed(2,2);
        seven = rotation_matrix_from_decomposed(2,3);
        eight = Input_elements(1,2);
        nine = rotation_matrix_from_decomposed(3,1);
        ten = rotation_matrix_from_decomposed(3,2);
        eleven = rotation_matrix_from_decomposed(3,3);
        twelve = Input_elements(1,3);

        Output = [one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve];
    else
        Output = [];
        disp('Input method is not recognized in this function. Please choose 1 or 2.');
        disp('1 = Rotation/Translation to 6 elements');
        disp('2 = 6 elements to Rotation/Translation');
        return;
    end

end




function eul = func_rotm2eul( R, varargin )
%ROTM2EUL Convert rotation matrix to Euler angles
%   EUL = ROTM2EUL(R) converts a 3D rotation matrix, R, into the corresponding
%   Euler angles, EUL. R is an 3-by-3-by-N matrix containing N rotation
%   matrices. The output, EUL, is an N-by-3 matrix of Euler rotation angles.
%   Rotation angles are in radians.
%
%   EUL = ROTM2EUL(R, SEQ) converts a rotation matrix into Euler angles.
%   The Euler angles are specified by the body-fixed (intrinsic) axis rotation
%   sequence, SEQ.
%
%   The default rotation sequence is 'ZYX', where the order of rotation
%   angles is Z Axis Rotation, Y Axis Rotation, and X Axis Rotation.
%
%   The following rotation sequences, SEQ, are supported: 'ZYX', 'ZYZ', and
%   'XYZ'.
%
%   Example:
%      % Calculates Euler angles for a rotation matrix
%      % By default, the ZYX axis order will be used.
%      R = [0 0 1; 0 1 0; -1 0 0];
%      eul = rotm2eul(R)
%
%      % Calculate the Euler angles for a ZYZ rotation
%      eulZYZ = rotm2eul(R, 'ZYZ')
%
%   See also eul2rotm

%   Copyright 2014-2017 The MathWorks, Inc.

%#codegen

% robotics.internal.validation.validateRotationMatrix(R, 'rotm2eul', 'R');
seq = 'XYZ'; %robotics.internal.validation.validateEulerSequence(varargin{:});

% Pre-allocate output
eul = zeros(size(R,3), 3 , 'like', R); %#ok<PREALL>
eulShaped = zeros(1, 3, size(R,3), 'like', R);

% The parsed sequence will be in all upper-case letters and validated
switch seq
    case 'ZYX'
        % Handle Z-Y-X rotation order        
        eulShaped = calculateEulerAngles(R, 'ZYX');

    case 'ZYZ'
        % Handle Z-Y-Z rotation order
        eulShaped = calculateEulerAngles(R, 'ZYZ');
        
    case 'XYZ'
        % Handle X-Y-Z rotation order
        eulShaped = calculateEulerAngles(R, 'XYZ');
end

% Shape output as a series of row vectors
eul = reshape(eulShaped,[3, numel(eulShaped)/3]).';

end

function eul = calculateEulerAngles(R, seq)
%calculateEulerAngles Calculate Euler angles from rotation matrix
%   EUL = calculateEulerAngles(R, SEQ) calculates the Euler angles, EUL,
%   corresponding to the input rotation matrix, R. The Euler angles follow
%   the axis order specified in SEQ. 

% Preallocate output
eul = zeros(1, 3, size(R,3), 'like', R);  %#ok<PREALL>

nextAxis = [2, 3, 1, 2];

% Pre-populate settings for different axis orderings
% Each setting has 4 values:
%   1. firstAxis : The right-most axis of the rotation order. Here, X=1,
%      Y=2, and Z=3.
%   2. repetition : If the first axis and the last axis are equal in
%      the sequence, then repetition = 1; otherwise repetition = 0.
%   3. parity : Parity is 0 if the right two axes in the sequence are
%      YX, ZY, or XZ. Otherwise, parity is 1.
%   4. movingFrame : movingFrame = 1 if the rotations are with
%      reference to a moving frame. Otherwise (in the case of a static
%      frame), movingFrame = 0.
seqSettings.ZYX = [1, 0, 0, 1];
seqSettings.ZYZ = [3, 1, 1, 1];
seqSettings.XYZ = [3, 0, 1, 1];

% Retrieve the settings for a particular axis sequence
setting = seqSettings.(seq);
firstAxis = setting(1);
repetition = setting(2);
parity = setting(3);
movingFrame = setting(4);

% Calculate indices for accessing rotation matrix
i = firstAxis;
j = nextAxis(i+parity);
k = nextAxis(i-parity+1);

if repetition
    % Find special cases of rotation matrix values that correspond to Euler
    % angle singularities.
    sy = sqrt(R(i,j,:).*R(i,j,:) + R(i,k,:).*R(i,k,:));    
    singular = sy < 10 * eps(class(R));
    
    % Calculate Euler angles
    eul = [atan2(R(i,j,:), R(i,k,:)), atan2(sy, R(i,i,:)), atan2(R(j,i,:), -R(k,i,:))];
    
    % Singular matrices need special treatment
    numSingular = sum(singular,3);
    assert(numSingular <= length(singular));
    if numSingular > 0
        eul(:,:,singular) = [atan2(-R(j,k,singular), R(j,j,singular)), ...
            atan2(sy(:,:,singular), R(i,i,singular)), zeros(1,1,numSingular,'like',R)];
    end
    
else
    % Find special cases of rotation matrix values that correspond to Euler
    % angle singularities.  
    sy = sqrt(R(i,i,:).*R(i,i,:) + R(j,i,:).*R(j,i,:));    
    singular = sy < 10 * eps(class(R));
    
    % Calculate Euler angles
    eul = [atan2(R(k,j,:), R(k,k,:)), atan2(-R(k,i,:), sy), atan2(R(j,i,:), R(i,i,:))];
    
    % Singular matrices need special treatment
    numSingular = sum(singular,3);
    assert(numSingular <= length(singular));
    if numSingular > 0
        eul(:,:,singular) = [atan2(-R(j,k,singular), R(j,j,singular)), ...
            atan2(-R(k,i,singular), sy(:,:,singular)), zeros(1,1,numSingular,'like',R)];
    end    
end

if parity
    % Invert the result
    eul = -eul;
end

if movingFrame
    % Swap the X and Z columns
    eul(:,[1,3],:)=eul(:,[3,1],:);
end

end

function R = func_eul2rotm2( eul, varargin )
%EUL2ROTM Convert Euler angles to rotation matrix
%   R = EUL2ROTM(EUL) converts a set of 3D Euler angles, EUL, into the
%   corresponding rotation matrix, R. EUL is an N-by-3 matrix of Euler rotation
%   angles. The output, R, is an 3-by-3-by-N matrix containing N rotation
%   matrices. Rotation angles are input in radians.
%
%   R = EUL2ROTM(EUL, SEQ) converts 3D Euler angles into a rotation matrix.
%   The Euler angles are specified by the body-fixed (intrinsic) axis rotation
%   sequence, SEQ.
%
%   The default rotation sequence is 'ZYX', where the order of rotation
%   angles is Z Axis Rotation, Y Axis Rotation, and X Axis Rotation.
%
%   The following rotation sequences, SEQ, are supported: 'ZYX', 'ZYZ', and
%   'XYZ'.
%
%   Example:
%      % Calculate the rotation matrix for a set of Euler angles
%      % By default, the ZYX axis order will be used.
%      angles = [0 pi/2 0];
%      R = eul2rotm(angles)
%
%      % Calculate the rotation matrix based on a ZYZ rotation
%      Rzyz = eul2rotm(angles, 'ZYZ')
%
%   See also rotm2eul

%   Copyright 2014-2017 The MathWorks, Inc.

%#codegen

% robotics.internal.validation.validateNumericMatrix(eul, 'eul2rotm', 'eul', ...
%     'ncols', 3);
% 
% seq = robotics.internal.validation.validateEulerSequence(varargin{:});

seq = 'XYZ';
R = zeros(3,3,size(eul,1),'like',eul);
ct = cos(eul);
st = sin(eul);

% The parsed sequence will be in all upper-case letters and validated
switch seq
    case 'ZYX'
        %     The rotation matrix R can be constructed as follows by
        %     ct = [cz cy cx] and st = [sy sy sx]
        %
        %     R = [  cy*cz   sy*sx*cz-sz*cx    sy*cx*cz+sz*sx
        %            cy*sz   sy*sx*sz+cz*cx    sy*cx*sz-cz*sx
        %              -sy            cy*sx             cy*cx]
        %       = Rz(tz) * Ry(ty) * Rx(tx)
        
        R(1,1,:) = ct(:,2).*ct(:,1);
        R(1,2,:) = st(:,3).*st(:,2).*ct(:,1) - ct(:,3).*st(:,1);
        R(1,3,:) = ct(:,3).*st(:,2).*ct(:,1) + st(:,3).*st(:,1);
        R(2,1,:) = ct(:,2).*st(:,1);
        R(2,2,:) = st(:,3).*st(:,2).*st(:,1) + ct(:,3).*ct(:,1);
        R(2,3,:) = ct(:,3).*st(:,2).*st(:,1) - st(:,3).*ct(:,1);
        R(3,1,:) = -st(:,2);
        R(3,2,:) = st(:,3).*ct(:,2);
        R(3,3,:) = ct(:,3).*ct(:,2);
        
    case 'ZYZ'
        %     The rotation matrix R can be constructed as follows by
        %     ct = [cz cy cz2] and st = [sz sy sz2]
        %
        %     R = [  cz2*cy*cz-sz2*sz   -sz2*cy*cz-cz2*sz    sy*cz
        %            cz2*cy*sz+sz2*cz   -sz2*cy*sz+cz2*cz    sy*sz
        %                     -cz2*sy              sz2*sy       cy]
        %       = Rz(tz) * Ry(ty) * Rz(tz2)
        
        R(1,1,:) = ct(:,1).*ct(:,3).*ct(:,2) - st(:,1).*st(:,3);
        R(1,2,:) = -ct(:,1).*ct(:,2).*st(:,3) - st(:,1).*ct(:,3);
        R(1,3,:) = ct(:,1).*st(:,2);
        R(2,1,:) = st(:,1).*ct(:,3).*ct(:,2) + ct(:,1).*st(:,3);
        R(2,2,:) = -st(:,1).*ct(:,2).*st(:,3) + ct(:,1).*ct(:,3);
        R(2,3,:) = st(:,1).*st(:,2);
        R(3,1,:) = -st(:,2).*ct(:,3);
        R(3,2,:) = st(:,2).*st(:,3);
        R(3,3,:) = ct(:,2);
        
    case 'XYZ'
        %     The rotation matrix R can be constructed as follows by
        %     ct = [cx cy cz] and st = [sx sy sz]
        %
        %     R = [            cy*cz,           -cy*sz,     sy]
        %         [ cx*sz + cz*sx*sy, cx*cz - sx*sy*sz, -cy*sx]
        %         [ sx*sz - cx*cz*sy, cz*sx + cx*sy*sz,  cx*cy]
        %       = Rx(tx) * Ry(ty) * Rz(tz)
        
        R(1,1,:) = ct(:,2).*ct(:,3);
        R(1,2,:) = -ct(:,2).*st(:,3);
        R(1,3,:) = st(:,2);
        R(2,1,:) = ct(:,1).*st(:,3) + ct(:,3).*st(:,1).*st(:,2);
        R(2,2,:) = ct(:,1).*ct(:,3) - st(:,1).*st(:,2).*st(:,3);
        R(2,3,:) = -ct(:,2).*st(:,1);
        R(3,1,:) = st(:,1).*st(:,3) - ct(:,1).*ct(:,3).*st(:,2);
        R(3,2,:) = ct(:,3).*st(:,1) + ct(:,1).*st(:,2).*st(:,3);
        R(3,3,:) = ct(:,1).*ct(:,2);
end

end




