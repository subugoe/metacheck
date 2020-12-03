<!-- badges: start -->
[![Main](https://github.com/subugoe/metacheck/workflows/.github/workflows/main.yaml/badge.svg)](https://github.com/subugoe/metacheck/actions)
[![Codecov test coverage](https://codecov.io/gh/subugoe/metacheck/branch/master/graph/badge.svg)](https://codecov.io/gh/subugoe/metacheck?branch=master)
[![CRAN status](https://www.r-pkg.org/badges/version/metacheck)](https://CRAN.R-project.org/package=metacheck)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

<div class="jumbotron">
  <h1>Open Access Metadata Compliance Checker</h1>
  <p>
    Automatically check metadata compliance for hybrid open access transformation contracts.
  </p>
  <p>
    <a class="btn btn-success btn-lg" href="articles/german.html" role="button">
      Check out an Example E-Mail.
    </a>
    <a class="btn btn-primary btn-lg" href="https://subugoe.github.io/hoad/newsletter.html" role="button">
      Sign up to the newsletter (german)
    </a>
  </p>
</div>

<div class="alert alert-info" role="alert">
  <strong>During the alpha release, only german data is supported.</strong>
  Stay tuned for an internationalised version.
</div>

## Why Metadata Compliance Matters

<p class="lead">
Open access grants and transformation contracts with publishers increasingly require licensing metadata.
</p>

<div class="panel panel-default">
  <div class="panel-heading" style="linkcolor:white;">
  [DFG](https://www.dfg.de) [Open Access Publication Funding](https://www.dfg.de/en/research_funding/programmes/infrastructure/lis/funding_opportunities/open_access_publication_funding/index.html) (Starting 2021):
  </div>
  <div class="panel-body">
  > "Funded institutions must generally agree to make publication metadata (including the cost data for the overall costs of publications) openly accessible via an infrastructure proposed by the DFG. "
  </div>
  <div class="panel-footer">
  [Guidelines and Supplementary Instructions](https://www.dfg.de/formulare/12_21/12_21_en.pdf), page 5
  </div>
</div>


## Supporting Libraries and OA Funders

<p class="lead">
The compliance checker helps libraries and other funders of open access publications professionalise their metadata monitoring.
</p>

<ul class="media-list row">
  <li class="media col-sm-6">
  <div class="media-left">
  <i class="fas fa-check-circle fa-3x"></i>
  </div>
  <div class="media-body">
  <h4 class="media-heading">Become Metadata Compliant</h4>
  Independently verify that your publications are compliant with the metadata requirements of funding agencies.
  </div>
  </li>
  <li class="media col-sm-6">
  <div class="media-left">
  <i class="fa fa-clipboard-list  fa-3x"></i>
  </div>
  <div class="media-body">
  <h4 class="media-heading">Identify Areas of Improvement</h4>
  Identify nonconforming metadata and target the publishers and publications to best improve your compliance.
  </div>
  </li>
</ul>
<ul class="media-list row">
  <li class="media col-sm-6">
  <div class="media-left">
  <i class="fa fa-envelope-open-text fa-3x"></i>
  </div>
  <div class="media-body">
  <h4 class="media-heading">Receive Emailed Reports</h4>
  Get high-quality reports parametrised for your institution and funded publications by email.
  </div>
  </li>
  <li class="media col-sm-6">
  <div class="media-left">
  <i class="fa fa-file-excel fa-3x"></i>
  </div>
  <div class="media-body">
  <h4 class="media-heading">Dig Down into your Data</h4>
  Use generated spreadsheets with your own tools and analyses.
  </div>
  </li>
</ul>
<ul class="media-list row">
  <li class="media col-sm-6">
  <div class="media-left">
  <i class="fa fa-comments fa-3x"></i>
  </div>
  <div class="media-body">
  <h4 class="media-heading">Get Answers</h4>
  Rely on the community of users and experts to interpret results and troubleshoot concompliant or missing metadata.
  <br><span class="label label-info">FAQs are coming soon.</span>
  </div>
  </li>
  <li class="media col-sm-6">
  <div class="media-left">
  <i class="fab fa-osi fa-3x"></i>
  </div>
  <div class="media-body">
  <h4 class="media-heading">Use Open Source for Open Access</h4>
  Co-create value for the community by using a compliance tool powered by open source software and based on open data.
  <br><span class="label label-success">Contributions are welcome.</span>
  </div>
  </li>
</ul>


## Technical Implementation

The Open Access Metadata Compliance Checker is powered by **metacheck**, an R package.

The package includes:

- compliance checks
- a parametrised rmarkdown compliance report
- a webapp to send e-mail reports

The package relies on metadata from the crossref API.
