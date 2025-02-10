# Time-Lagged Recurrences (TLR, $\alpha_\eta$)

Python code and Jupyter notebooks support the manuscript "Revisiting the Predictability of Dynamical Systems: A New Local Data-Driven Approach," which introduces the Time-Lagged Recurrences (TLR) as a novel predictability index.

## Introduction

 
## Content

### Scripts

Functions for computing TLR ($\alpha_\eta$), along with the other two local dynamical indices: local dimension $d$ and persistence $\Theta$.
* [local_indices.py](scripts/local_indices.py)

Functions for postprocessing and visualization.
* [postprocessing.py](scripts/postprocessing.py)

### Example

Driver file for computing TLR ($\alpha_\eta$), using the Lorenz-63 system as an example.
* [driver_sh.sh](example/driver_sh.sh)

Driver file for reproducing Figure 2 in the main text of the manuscript.
* [driver_sh_plotting.sh](example/driver_sh_plotting.sh)

### Data

All data used in this paper are available. Datasets from Brunton et al. (2017) [1] are in folder [datasets](data/datasets), while the Julia scripts for generating others are in folder [julia_code](data/julia_code). The ERA5 reanalysis data used in this study are available at [ERA5](https://cds.climate.copernicus.eu/#!/search?text=ERA5&type=dataset).


[1] Brunton, Steven L., et al. "Chaos as an intermittently forced linear system." Nature communications 8.1 (2017): 19.

