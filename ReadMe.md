# High-Performance Scientific Computing with Modern Fortran and OpenMP

A research-oriented **high-performance computing (HPC)** implementation of the **phase-field equations** for simulating microstructure evolution in materials science.

This project demonstrates how modern **Fortran-based scientific software** can be engineered using **parallel programming**, **object-oriented design**, and **performance-aware architecture** while maintaining portability across **Linux (WSL included)** and **Windows environments**.

The framework is designed not only as a simulation tool but also as a demonstration of **professional HPC software development practices** used in computational physics and materials science applications.

---

## Project Overview

The **phase field equations** are nonlinear partial differential equation widely used in:

* Phase separation dynamics
* Computational materials science research

This implementation focuses on transforming a traditional scientific codebase into a **performance-oriented HPC application** by integrating:

* Shared-memory parallelization using **OpenMP**
* Modern **Object-Oriented Fortran (OOP)**
* Modular architecture with **Fortran Submodules**
* Cross-platform build system using **CMake**
* Performance instrumentation and benchmarking utilities
* Python-based visualization pipeline for simulation output

---

## Core HPC Features

### Parallel Programming with OpenMP

The computational kernels are parallelized using **OpenMP** to exploit multi-core CPU architectures.

Implemented parallelization strategies include:

* Loop-level parallelism
* Shared-memory workload distribution
* Thread-safe numerical kernels
* Performance scaling on multi-core processors

Example compilation with OpenMP:

```bash
gfortran -fopenmp
```

---

### Modern Fortran Architecture

This project is intentionally designed using modern Fortran standards rather than procedural legacy code.

Implemented modern features:

* Modules
* Derived Types
* Encapsulation
* Type-bound Procedures
* Object-Oriented Programming Design
* Explicit Interfaces
* Fortran Preprocessor Macros
* Submodules for compilation efficiency
* Memory-safe architecture

Example architecture philosophy:

```mermaid
flowchart LR

A["Modern Fortran OOP Design"]
B["Numerical Solver"]
C["OpenMP Parallelization"]
D["Performance Optimization"]
E["Scientific Output"]
F["Python Visualization"]

A --> B
B --> C
C --> D
D --> E
E --> F
```

---

### Performance-Oriented Engineering

Scientific codes are rarely performance-optimal after initial implementation.

This project integrates performance engineering concepts including:

* Compiler optimization strategies
* Loop unrolling
* Vectorization
* Memory layout optimization
* Stack allocation optimization
* Performance timing utilities
* Runtime benchmarking modules

Compiler optimizations:

```bash
-O3 -march=native -funroll-loops -ftree-vectorize
```

---
## Project Structure


```
Project/
│
├── app/
│   └── Main application driver
│
├── src/
│   ├── Core numerical modules
│   ├── Solver implementation
│   ├── Grid generation utilities
│   ├── Initialization routines
│   ├── Computational kernels
│   ├── Parallel execution modules
│   ├── Input/Output handlers
│   └── Performance analysis modules
│
├── visualization/
│   └── Python post-processing and visualization scripts
│
├── scripts/
│   ├── Windows build automation
│   └── Linux/WSL build automation
│
├── build/
│   └── Generated build artifacts
│
├── CMakeLists.txt
│
└── README.md
```

---

## Cross-Platform Build Support

The project supports both **Linux** and **Windows** environments.

Supported platforms:

* Linux
* Ubuntu WSL
* Windows PowerShell
* GCC / MinGW environments

Compiler requirement:

```text
gfortran (GNU Fortran Compiler)
intel (ifx)
```
---

## Visualization Pipeline

Simulation outputs can be visualized using the included Python post-processing script.

Features:

* 2D plotting
* Microstructure evolution visualization

Run visualization:

```bash
python python_visualization.py
```

Typical output:


```mermaid
flowchart LR

A["Simulation Output"]
B["Data Files"]
C["Python Visualization"]
D["Scientific Output"]
E["Plots"]

A --> B
B --> C
C --> D
D --> E
```

---

## Technical Stack

Languages:
* Modern Fortran
* Python

Parallel Programming:

* OpenMP

Build System:

* CMake

Compilers:

* GNU Fortran (gfortran)
*  Intel (ifx)

Platforms:

* Linux
* Windows
* WSL

Scientific Domain:

* Computational Materials Science
* Phase-Field Modeling
* Numerical PDE Solvers
* High Performance Computing

---


## Research and Educational Purpose

This project is intended for:

* Computational science students
* HPC developers
* Scientific software engineers
* Materials science researchers
* Researchers learning parallel programming in Fortran

It demonstrates how scientific programming approaches can evolve into modern **performance-oriented scientific software engineering**.

---

## Future Improvements

Planned improvements:

* MPI distributed memory parallelization
* Hybrid MPI + OpenMP implementation
* GPU acceleration (OpenACC / CUDA Fortran)
* SIMD vectorization benchmarking
* Cache-aware optimization
* Automated performance profiling
* Continuous Integration testing pipeline

---

## Why This Project Matters

Many scientific codes are written to produce correct results.

Few are engineered for performance.

This repository demonstrates an important principle in scientific computing:

```
Numerical correctness solves the problem.
Performance engineering makes the solution scalable.
```

The goal is not only solving the **Phase field equations**, but demonstrating how modern HPC developers design research-grade computational software.

---

## Author

**Shahid Maqbool**

Computational Science | Scientific Computing | High Performance Computing | Modern Fortran | Parallel Programming | Performance Engineering

---

## License

Open-source project intended for research and educational use.

---

### Date: 02 July 2026
