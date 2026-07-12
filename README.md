# CMake Module Library
<!--
SPDX-FileCopyrightText: 2026 AlgorIT Software Consultancy <https://github.com/algoritnl>
SPDX-License-Identifier: CC0-1.0
-->

[![REUSE status](https://api.reuse.software/badge/github.com/algoritnl/cmake-module-library)](https://api.reuse.software/info/github.com/algoritnl/cmake-module-library)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/algoritnl/cmake-module-library/main.svg)](https://results.pre-commit.ci/latest/github/algoritnl/cmake-module-library/main)
[![CMake Unit Test](https://github.com/algoritnl/cmake-module-library/actions/workflows/cmut-run.yaml/badge.svg)](https://github.com/algoritnl/cmake-module-library/actions/workflows/cmut-run.yaml)
![CMake 3.31+](https://img.shields.io/badge/CMake-3.16...4.3%2B-blue?logo=cmake)

This repository serves as a centralized collection of custom CMake modules designed to simplify, standardize, and enhance project configuration. Inclusion of this library facilitates the reduction of boilerplate code and the enforcement of consistent build patterns across repositories.

## Key Features

- **Reusable Logic**: Contains modular, encapsulated CMake functions and macros.
- **Standardization**: Enforces consistent build patterns across multiple repositories.
- **Easy Integration**: Simple include mechanisms to drop these utilities into any CMake-based project.

## Highlighted Utility: multiple_choice

One of the core utilities provided in this library is the multiple_choice function, located in the cmake/ subdirectory. This function is designed to handle robust input validation and option selection within your CMakeLists.txt files.

### Function Signature

```text
multiple_choice(
  <var>
  VALID_VALUES <val1> [<val2> ...]
  [DEFAULT <default_val> [<default_val2> ...]]
  [VALUE_MODE SINGLE|MULTI|SEQUENCE]
  [TYPE <type>]
  [HELP <help_string>]
  [DEFAULT_ON_ERROR]
  [FATAL_ERROR]
)
```

### Getting Started

Implementation requires the following steps:

1. **Project Integration**: Clone the repository or incorporate it as a Git submodule.
1. **Path Configuration**: Append the cmake/ directory to the CMAKE_MODULE_PATH:

   ```cmake
   list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/path/to/repo/cmake")
    ```

1. **Module Inclusion**: Include the desired module:

    ```cmake
    include(MultipleChoice)
    ```

1. **Function Execution**: Example defining valid choices:

    ```cmake
    # VALUE_MODE SINGLE is the default.
    # When DEFAULT is omitted, the first valid value ("red") is assigned as the default.
    multiple_choice(COLOR VALID_VALUES red green blue)
    ```
