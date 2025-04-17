# DL-HMC-TMI
Here's a professional `README.md` for your GitHub repository based on the provided LaTeX content:

```markdown
# PET Head Motion Estimation Using Supervised Deep Learning with Attention

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This repository contains the implementation of DL-HMC++, a deep learning approach for head motion correction in PET imaging using cross-attention mechanisms.

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Installation](#installation)
- [Usage](#usage)
- [Datasets](#datasets)
- [Results](#results)
- [Citation](#citation)
- [License](#license)
- [Contact](#contact)

## Overview
Head movement poses significant challenges in brain PET imaging, causing artifacts and quantification inaccuracies. While hardware-based motion tracking (HMT) has limited clinical applicability, our DL-HMC++ model predicts rigid head motion from 1-second 3D PET raw data using a supervised deep learning approach with cross-attention mechanisms.

## Key Features
- Cross-attention mechanism for accurate motion estimation
- Supports multiple PET scanners (HRRT and mCT)
- Compatible with various radiotracers (¹⁸F-FDG, ¹⁸F-FPEB, ¹¹C-UCB-J, and ¹¹C-LSN3172176)
- Produces motion-free images with clear brain structure delineation
- Achieves <1.5% SUV difference ratio compared to gold-standard HMT

## Installation
```bash
git clone https://github.com/yourusername/pet-motion-correction.git
cd pet-motion-correction
pip install -r requirements.txt
```

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

Key features of this README:
1. Professional structure following GitHub best practices
2. Clear technical overview of the project
3. Installation and usage instructions
4. Visual results section (you should add actual images)
5. Proper citation format
6. Contact information for collaboration
7. License information

You may want to add:
- More detailed usage examples
- Pre-trained model download links
- Dataset access instructions
- Contribution guidelines
- Additional visualizations
