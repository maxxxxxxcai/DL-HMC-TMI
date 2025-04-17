# PET Head Motion Estimation Using Supervised Deep Learning with Attention (Submitted to TMI)
# Abstract
Head movement poses a significant challenge in brain positron emission tomography (PET) imaging, resulting in image artifacts and tracer uptake quantification inaccuracies. Effective head motion estimation and correction are crucial for precise quantitative image analysis and accurate diagnosis of neurological disorders.
To overcome this limitation, we propose a deep-learning head motion correction approach with cross-attention (DL-HMC++) to predict rigid head motion from one-second 3D PET raw data.
DL-HMC++ is trained in a supervised manner by leveraging existing dynamic PET scans with gold-standard motion measurements from external HMT.
We evaluate DL-HMC++ on two PET scanners (HRRT and mCT) and four radiotracers ($^{18}$F-FDG, $^{18}$F-FPEB, $^{11}$C-UCB-J, and $^{11}$C-LSN3172176) to demonstrate the effectiveness and generalization of the approach in large cohort PET studies.
Quantitative and qualitative results demonstrate that DL-HMC++ consistently outperforms benchmark motion correction techniques, producing motion-free images with clear delineation of brain structures and reduced motion artifacts that are indistinguishable from ground-truth HMT.
Brain region of interest standard uptake value (SUV) analysis exhibits average difference ratios between DL-HMC++ and ground-truth HMT to be 1.2\%$\pm$0.5\% for HRRT and 0.5\%$\pm$0.2\% for mCT.
DL-HMC++ demonstrates the potential for data-driven PET head motion correction to remove the burden of HMT, making motion correction accessible to clinical populations beyond research settings.

## Authors
This work is developed by:

- **Zhuotong Cai** (Institute of Artificial Intelligence and Robotics, Xi'an Jiaotong University & Department of Radiology and Biomedical Imaging, Yale University)
- **Tianyi Zeng** (Department of Radiology and Biomedical Imaging, Yale University)
- **Jiazhen Zhang** (Department of Biomedical Engineering, Yale University)
- **Eléonore V. Lieffrig** (Department of Biomedical Engineering, Yale University)
- **Kathryn Fontaine** (Department of Radiology and Biomedical Imaging, Yale University)
- **Chenyu You** (Department of Electrical and Computer Engineering, Yale University)
- **Enette Mae Revilla** (United Imaging Healthcare)
- **James S. Duncan** (Departments of Radiology, Biomedical Engineering, and Electrical Engineering, Yale University)
- **Yihuan Lu** (United Imaging Healthcare)
- **John A. Onofrey** (Departments of Radiology, Biomedical Engineering, and Urology, Yale University)

*(Zhuotong Cai and Tianyi Zeng contributed equally to this work)*

## Usage
```python
from dl_hmc import MotionCorrector

# Initialize model
model = MotionCorrector(device='cuda')

# Load PET raw data
pet_data = load_your_pet_data()

# Predict motion parameters
motion_params = model.predict(pet_data)

# Apply motion correction
corrected_images = apply_correction(pet_data, motion_params)
```

## Datasets
The model was evaluated on datasets from:
- High Resolution Research Tomograph (HRRT)
- Siemens Biograph mCT

## Results
Quantitative results compared to ground-truth HMT:
| Scanner | Average SUV Difference Ratio |
|---------|-----------------------------|
| HRRT    | 1.2% ± 0.5%                 |
| mCT     | 0.5% ± 0.2%                 |

Sample motion-corrected images:
![Example Results](docs/images/results_sample.png)

## Citation
If you use this work, please cite:
```bibtex
@article{cai2024pet,
  title={PET Head Motion Estimation Using Supervised Deep Learning with Attention},
  author={Cai, Zhuotong and Zeng, Tianyi and Zhang, Jiazhen and Lieffrig, Eléonore V and Fontaine, Kathryn and You, Chenyu and Revilla, Enette Mae and Duncan, James S and Lu, Yihuan and Onofrey, John A},
  journal={IEEE Journal},
  year={2024}
}
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For questions or collaborations, please contact:
- Zhuotong Cai: zhuotong.cai@yale.edu
- Tianyi Zeng: tianyi.zeng@yale.edu
- John Onofrey: john.onofrey@yale.edu
```
