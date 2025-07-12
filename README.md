# cQuant-energy-analyst-challenge
Hello everyone who is taking a look at this repo and welcome to my work on the cQuant coding challenge!

### Introduction

**Features:**
- Automatic formatting and environment reproducibility via pre-commit hooks
- GitHub actions that prevent unformatted code from being pushed to the main branch (and provide helpful suggestions on rejected pull requests!)
- Documentation [roxygen](https://roxygen2.r-lib.org) style
- Quarto-powered reports for pretty formatting of results and analysis _(if I have time to actually create these)_

**Style:**
The style guidelines were obtained from the [Google Style Guide](https://google.github.io/styleguide/Rguide.html) and the code itself strives to make use of the [tidyverse](https://www.tidyverse.org) and its philosophy for doing data analysis in R.

**Note:** This repository is extremely over-engineered to display some things I think are useful when working on collaborative projects that could scale. For collaborative projects, I've found having maintaining a reproducible package environment and enforcing formatting can save a lot of problems down the road, and for larger projects, GitHub actions is a nifty way to automatically safeguard the main branch. 

(Also I know emojis are an AI red flag, but I genuinely enjoy them in GitHub READMEs and this file, like all other code in this repository, was created without the use of any LLM tool)

**Future Work:**
- If I had more time, I would love to learn about the R package ecosystem and develop this into a full-fledged package (using Hadley Wickham's incredible [online resource](https://r-pkgs.org) as a guide). Besides being a great learning opportunity, it would allow roxygen to actually create in-editor documentation for the functions, making it easier to continue working on this and for others to access it.
- Additionally, I'd love to incorporate a GitHub Action workflow for automated linting via a tool like [lintr](https://lintr.r-lib.org).
- Although full integration tests don't really fit the scope of this project, integration/unit tests are generally something I like to setup in an automated fashion just to help avoid hidden bugs.

## ⚙️ Getting Started
1. **Verify R is installed by running:**
```bash
R --version
```
- If R has been setup properly, this command should print out the version you're currently running.
- If not downloaded, you can download it [here](https://www.r-project.org) (or with your package manager of choice).
2. **Clone the repository and navigate into it**
```bash
git clone https://github.com/sethbassetti/cQuant-energy-analyst-challenge.git
cd cquant-energy-analyst-exercise
```
3. **Install all project dependencies (using renv)**
```bash
Rscript install.R
```

## 🚀 Usage
Once you've cloned the repository and installed all necessary dependencies, you're set! Below I'll describe the layout of this repository and how you can reproduce the results:

### Project Structure
```
📦 cQuant-energy-analyst-challenge
├─ R/              # Where all of the helper modules live (dataUtils.R, etc...)
├─ data/           # Raw input data
├─ output/         # Generated files (plots, etc...)
├─ main.R          # Entry point to run the analysis
├─ install.R       # Installs renv and then syncs all project dependencies
├─ .githooks       # Where the pre-commit hook lives
├─ .github         # Github Actions CI Workflow
├─ renv.lock       # Stores all project dependencies for reproducibility
└─ LICENSE         # MIT License
```

### Reproducing Analysis
_Fill this out when I actually write the analysis code_

### Reproducing Figures
_Fill this out when I actually create the figures_

## 🤝 Contributing
If you'd like to contribute, please fork the repo and open a pull request. There are a few things to note below that help enforce a clean, consistent, and _tidy_ codebase.

### Pre-commit hooks
To ensure a consistent style for this codebase, styling through the [Air](https://posit-dev.github.io/air/) tool is enforced.

To activate pre-commit hooks so that all code is formatted prior to a commit, you can install the [Air command line tool](https://posit-dev.github.io/air/cli.html) and enable the pre-commit hook with this command:
```bash
git config core.hooksPath .githooks
```

Additionally, the pre-commit hook ensures that any new libraries you use are added to the renv.lock file to ensure future reproducibility.

### Github actions
Any pull requests and pushes to the main branch are subject to a formatting github actions check. If this fails, suggestions will be provided, and you can resubmit the pull request.
