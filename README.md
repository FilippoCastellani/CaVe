<!-- Header -->

<p align="center">
    <img src="Meta_Media/Logo_Politecnico_Milano.png" alt="Polimi logo" width="30%" height="30%">
</p>


--------------


# CaVe: Castellani - Vettori

## Scope: 
These projects were developed as part of the course of [Biomedical Signal Processing & Medical Images](https://www11.ceda.polimi.it/schedaincarico/schedaincarico/controller/scheda_pubblica/SchedaPublic.do?&evn_default=evento&c_classe=766825&polij_device_category=DESKTOP&__pj0=0&__pj1=4b2fa48767f0da38e5c6eff2bf408a34), held by Prof. M. Signorini.
During the span of the course, processing and elaboration techniques for biomedical signals and medical images were studied.

## What is it ?
Two projects realized by a team of students from Politecnico di Milano.

##### Authors: Filippo Castellani, Gaia Vettori


## What does it do ?

These projects deal with two very different topics:
 1. Hypnogram estimation from EEG signals during sleep.
 2. Quasi-Automatic Segmentation of lesions in brain MRI images.

During the course of the project, the **aim** was to **develop algorithms** that could sove the tasks **and critically evaluate the obtained results**.
In order to do so a starting bibliography on the state of the art in the task-related field was given in order to kickstart the research.
Consequently, the studied algorithms were implemented in Matlab and tested on real data furnished by the professor.

# Brief description of the projects:

### Project 1: Hypnogram estimation from EEG signals during sleep.

**Dataset:**

    - 1         = number of subjects
    - 8 hours   = EEG recording length
    - 512 Hz    = sampling frequency
    - FP1       = electrode position (frontal lobe)


**Purpose:**
- To characterize the sleep stages of the patient (NREM 1/2/3/4 and REM)

**Method:**

- Pre-processing of the signal (band-pass filtering [0.1-90 Hz] + 50 Hz Electric Noise removal)
 - ...
<!-- - Through the estimation of the power spectral density of epochs of 3 minutes that is done with the modified Bartlett periodogram which uses a Hann/Hamming window of 30 seconds.
        ◦ 
    • For each obtained PSD (Power Spectral Density) Γ(f) the following procedure is performed:
        ◦ 
        ◦ -->

**Results:**

<p align="center">
    <img src="Meta_Media/Hypnogram_result.jpg" alt="Hypnogram result" width="60%" height="60%">
    <br>
    <i> Click on the image to see the full size version </i>
</p>

# Project 2: Quasi-Automatic Segmentation of lesions in brain MRI images.

> **Q: Why is it called Quasi-Automatic Segmentation ?**
> 
> **A:** Quasi-Automatic means that the user has to manually select the region of interest (ROI) in the first slice of the MRI image, and then the algorithm will automatically segment the lesion in the other slices of the image.



--------------------------------------------------------------------------------------------------

## What software is required to run the projects scripts ?
 - **Matlab R2020b** was used for the development of the projects. So at least this version is recommended to run the scripts.


