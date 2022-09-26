# Implementing web-based discrete choice experiments with Qualtrics, R and Amazon Web Service (AWS)

This repository contains a step by step guide to implement a survey with a discrete choice experiment (DCE) in Qualtrics. It is part of the paper "Implementing web-based discrete choice experiments in transportation" that is currently being reviewed for publication in [Transportation Research Procedia](https://www.sciencedirect.com/journal/transportation-research-procedia?_gl=1*1vrwepw*_ga*NjY1MTg2NDMzLjE2NjM5MjE3MTU.*_ga_4R527DM8F7*MTY2MzkyMTcxNS4xLjAuMTY2MzkyMTcyNi4wLjAuMA..).

The output is a survey like [this](https://ivtethz.fra1.qualtrics.com/jfe/form/SV_9ykT8FWUU31yjGu) one in Qualtrics. Click on the link and fill out the survey to get a first impression.

## Content

1. Simple choice design
2. R Code to display a choice situation in Qualtrics in two ways
   1. Create a picture of each choice situation (picture-based approach)
      - Upload it to AWS bucket
      - Show picture on the fly in Qualtrics
   2. Create a JSON file of each choice situation (matrix table-based approach)
      - Upload it to AWS bucket
      - Load data with Qualtrics Web Service
      - Display data in Qualtrics Matrix Table
3. Qualtrics survey template
   1. A template to load in Qualtrics

## Requirements

### AWS

In order for the example to work, an account on [Amazon Simple Storage Service (S3)](https://aws.amazon.com/s3/?tag=mochaglobal20-20) is needed. See [this page](https://aws.amazon.com/s3/pricing/) for AWS pricing. For the purpose of implementing DCEs in the proposed way, there are no to very low costs. This example makes use of the R package [aws.s3](https://github.com/cloudyr/aws.s3) to connect and transfer files even though the [AWS Command Line Interface](https://docs.aws.amazon.com/cli/index.html) is recommended for transfering many files at once.

1. To use the package, you will also have to enter your credentials into R. Your keypair can be generated on the IAM Management Console under the heading Access Keys. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten.

### R

To run the scripts, R ([The R Project for Statistical Computing](https://www.r-project.org/)) and the [R Studio Editor](https://www.rstudio.com/products/rstudio/download/) is needed. Both are freely available under the links provided. Please use the latest versions if possible.

### Qualtrics

Unfortunately, only part of the example can be used with the free account of [Qualtrics](https://www.qualtrics.com/uk/core-xm/). The free version of Qualtrics only allows for the picture-based approach whereas the matrix table-based approach requires JavaScript and hence a Qualtrics license.

## Guide

1. Check that requirements from above are set up.
2. Download or clone repository.
3. Open the R project file "dce_sp.Rproj" on your machine.
4. Run script "create_choice_situations.R". Explanations are given in the script itself and the functions loaded from "helper_functions.R".
5. Download Qualtrics template "DCE_SP.qsf" and import it to Qualtrics.














