connectomicsPerspectivesPaper
=============================
Set of tools and scripts to generate all the data required for the perspectives paper.

Right now it includes the new datasets that needs to be analyzed, the codes from some participants and several scripts to compute the desired statistics (ROCs, PRs, motifs, ...)


Updates
-------
* 7 Oct: The ECML proceedings from the workshop are almost ready (volume 46). You can find the final draft of the volume in the ECML_proceedings folder.


Datasets
========
For the perspectives paper we are focusing on two different datasets. You can download them here:

[Download datasets](https://www.dropbox.com/sh/gibx9hz0p4u46ts/AABjgtXS6yNZkXWLIimHOduXa?dl=0)

Note: This download location contains more datasets than actually needed. The reduced datasets are currently being uploaded here:

[Download reduced datasets](https://www.dropbox.com/sh/ww5146ypgbi93i0/AAA3DpllU9dpefZOZKNpiiNwa?dl=0)

Original variations
-------------------
These are variations of the original test and valid networks but exploring different values of camera noise, framerate and light scattering. These are all variables that can be tuned in the real experiments, and it is interesting to explore the performance of the algorithms in these conditions.
Inside each folder (test and valid) you will find a set of fluorescence traces named:

    fluorescence_network_noise?_ls?_rate?.txt

Where 'network' will either be valid or test, and each ? goes from 1 to 3 for each of the explored parameters. The parameters correspond to the following values:

1. noise = [0, 0.03, 0.06] This is the white noise added directly to the fluorescence signal. Challenge value was the middle one.
2. ls = [0, 0.03, 0.1] Characteristic length of the light scattering effect. Challenge value was the middle one.
3. rate = [25, 50, 100] Frames per second (FPS) of the fluorescence signal. Challenge value was the middle one.

Each of the fluorescence files for a given network (the 3x3x3 combinations) have been generated from the same spiking data, so you should be able to test the performance of the algorithms with exactly the same underlying dynamics.


Small datasets
--------------
This is the main dataset of the post-verification phase. It consists of N=100 networks with a 20% of inhibitory neurons (blocked) and a fixed average clustering coefficient, namely 0.2, 0.3 and 0.5. We provide 50 different networks for each clustering level. The network dynamics are divided in three groups: 

1. Low bursting (0.05 Hz). 
2. Normal bursting (0.1 Hz). 
3. High bursting (0.2 Hz).

In total we have 50 network realizations with 3 bursting rates and 3 levels of clustering (450 networks in total).

Additional notes
----------------
1. You should not need to retrain your algorithms.
2. Given that many participants also submited results with inhibition we could also include these datasets.


Participants codes
==================
It includes the codes from the following teams:

1. AAAGV
2. Ildefons
3. Lukasz8000
4. Konnectomics
5. GTE (benchmark)

I believe there is at least another code publicly available... 

Participants results
====================
We are gathering as many results as possible from the participants with the datasets described above. The csv files with the results are currently being uploaded and will be available here:

[Download results](https://www.dropbox.com/sh/1bwpln36lkz0mqk/AADrMbM26Vezr_XgEcD3sMlra?dl=0)

This is the current state of the process:

Challenge
---------
1. This folder contains the original results of the challenge for the top 20 participants (both valid and test networks)

AAAGV
-----
1. Original-variations: missing permutations on noise levels 1 and 2.
2. Small: missing low-bursting and some CC levels (Javier is assigned)

Ildefons
--------
1. Missing everything (Bisakha is assigned)

Lukasz8000
----------
1. Original-variations: got the full set for one of the networks
2. Small: missing

Konnectomics
------------
1. Missing everything

GTE (benchmark)
---------------
1. Original-variations: running (Javier is assigned)
2. Small: complete

DJMN
----
1. Original-variations: complete
2. Small: missing


Scripts and metrics
===================
Things we want to compute for each participant and dataset:

* ROCs - curves and AUC
* PRs - curves and AUC
* Motifs - orders 2 and 3 at a given reconstruction threshold
* Clustering coefficients at a given reconstruction threshold
* Graph similarity
* False discovery rate (at least for one instance)
* ...

Figures
=======
Folder containing some figures related to the computed metrics

Questions
==========
If you have specific questions about the datasets, please ask them directly to me at orlandi(at)ecm.ub.edu



