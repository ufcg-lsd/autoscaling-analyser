# Autoscaling-analyser

### Purpose
The purpose of this project is to analyse auto-scaling strategies based on the
ADI metric proposed by Marco A. S. Netto on the "Evaluating Auto-scaling Strategies for Cloud Computing Environments" article. The implementation was developed based on the rules and parameters of the article.

### Auto-scaling Demand Index

The Auto-scaling Demand Index (ADI) as quoted by Marcos 

> "is the sum of all distances computed between each utilisation level reported by the system and the target utilisation interval set by the user. [...] ADI is convenient because it employs the same metric to evaluate (or, more precisely, penalise) both
unacceptable QoS and resource underutilisation."

### Organization of the repo

#### data

The data directory is supposed to keep the system monitoring data files that you want to evaluate

#### images

Stores images related to the project such as an ADI calculation example

#### src

The ADI Evaluation algorithm

#### tests

Test cases to check if the algorithm is working as expected
