# MTSvieweR: a database of mitochondrial proteins integrating

[![](https://img.shields.io/badge/online-dashboard-red)](https://neurobioinfo.github.io/MTSvieweR)  [![](https://img.shields.io/badge/Docker-mtsviewer-blue)](https://hub.docker.com/r/saeidamiri1/mtsviewer) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7768427.svg)](https://doi.org/10.5281/zenodo.7768427) 

-------------

Welcome to MTSviewer's repository, a database for the study of mitochondrial proteins which integrates AlphaFold structures, cleavage predictions, N-terminomics, and genetic variants.

## Contents
-  [Features](#features)
-  [Online Dashboard](#online-dashboard)
-  [Docker](#docker)
-  [Contributing](#contributing)
-  [Citing](#citing)


### Features
- MTS predictions
- MPP cleavage sites
- Genetic variants
- Pathogenicity predictions
- N-terminomics data
- Structural visualization using AlphaFold models

All of the raw data and in-house Python scripts used in the MTSviewer build are accessible and free to [download](https://drive.google.com/drive/folders/1L32pcbeUH-WR8ZTU4xTFvDV0XxG1WPbr?usp=sharing).

:hammer: **Please note: if you only scroll through the "Gene List", the list will be truncated alphabetically after all genes starting with S. To overcome this, you must search your gene of interest, or type the beginning letter and all of the genes will be available!**

### Online Dashboard
It is accessible via [https://neurobioinfo.github.io/MTSvieweR](https://neurobioinfo.github.io/MTSvieweR)


### Docker
The MTSvieweR container is accessible on [docker's hub](https://hub.docker.com/r/saeidamiri1/mtsviewer). If you'd like to run it using Docker, please follow these instructions:
```
docker run --rm -p 3838:3838 saeidamiri1/mtsviewer:1.0.3
```

### Contributing
Any contributions or suggestions are greatly appreciated. To initiate a discussion about a new feature or a bug fix, it's typically best to open a GitHub issue. Once we reach a consensus on the way forward, you can fork the repository, make the necessary changes (using the dev branch), and then create a pull request (PR). Please ensure that PRs are targeted towards the dev branch.

If you come across a bug, kindly submit a comprehensive GitHub issue, and we'll respond promptly to address the issue.

### Citing
If you use MTSviewer in your research, please consider citing our paper: 

Bayne, A. N., Dong, J., Amiri, S., Farhan, S. M., & Trempe, J. F. (2023). MTSviewer: A database to visualize mitochondrial targeting sequences, cleavage sites, and mutations on protein structures. Plos one, 18(4), e0284541. [https://doi.org/10.1371/journal.pone.0284541](https://doi.org/10.1371/journal.pone.0284541)

See also our paper on [PlOS ONE](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0284541).

### License
This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/neurobioinfo/MTSvieweR/blob/main/LICENSE) file for details
