# SQRLab: A Digital Twin for ⁴⁰Ca⁺ Trapped Ion Experiments

`SQRLab` is a computational project dedicated to creating a high-fidelity digital twin of a surface ion trap experiment for ⁴⁰Ca⁺ ions. By leveraging numerical simulations in Julia, this project aims to model the behavior of trapped ions, simulate key quantum operations, and explore the effects of realistic experimental parameters.

The project's development involved establishing a stable simulation environment by resolving critical package dependencies and successfully implementing core single-qubit operations. The ultimate goal is to create a predictive model that can accelerate the design, calibration, and operation of real quantum hardware.

## Key Concepts

-   **Surface Ion Traps:** Microfabricated devices that use a combination of static (DC) and oscillating (RF) electric fields to confine charged particles (ions) in a vacuum. They are a leading platform for quantum computing and precision sensing.
-   **Digital Twin:** A virtual representation of a physical device or system. In this context, it's a suite of simulations that mirrors the behavior of a specific ion trap, allowing for virtual experiments and analysis of quantum phenomena like Rabi oscillations and Ramsey interferometry.

---

## Key Features & Accomplishments

-   **Stable Simulation Environment:** Identified and resolved a critical version conflict between `IonSim.jl` and its dependency `Optim.jl`. This established a reproducible environment for the team that avoids manual source code changes.
-   **Single-Qubit Operations:** Successfully implemented and simulated fundamental single-ion dynamics, including:
    * **Rabi Oscillations:** Modeled the population dynamics of a Ca⁺ ion under the influence of laser pulses.
    * **Ramsey Interferometry:** Simulated Ramsey experiments by observing population changes with respect to wait time to measure phase shifts.
-   **Realistic Experimental Modeling:** Advanced the model by incorporating factors that reflect real-world conditions:
    * **Laser & Magnetic Fields:** Investigated the effects of laser detuning and magnetic flux shifts on ion behavior.
    * **Thermal States:** Modeled the ion with an initial thermal state, observing the characteristic decay in Rabi oscillation amplitude due to the incoherent sum of different initial Fock states.

---

## Technology Stack

This project is built on the **Julia** programming language and its scientific computing ecosystem.

-   **Language:** **Julia**
-   **Core Libraries:**
    * `IonSim.jl` v0.5.1
    * `Optim.jl` v1.11.0
    * `QuantumOptics.jl` v1.2.3
    * `PyPlot.jl` v2.11.6
    * `IJulia.jl` v1.29.0

---

## Getting Started

### Prerequisites

-   A working installation of the **Julia** programming language.

### Installation

1.  **Clone the Repository:**
    ```sh
    git clone <your-repository-url>
    cd SQRLab
    ```
2.  **Enter Julia's Package Manager:**
    Launch the Julia REPL and press `]` to enter the package manager.
    ```julia
    (@v1.10) pkg>
    ```
3.  **Activate the Project Environment:**
    ```julia
    (@v1.10) pkg> activate .
    (SQRLab) pkg>
    ```
4.  **Install Dependencies:**
    Install the specific package versions required for the project to function correctly. The version for `Optim.jl` is especially important to avoid dependency conflicts.
    ```julia
    (SQRLab) pkg> add IonSim@0.5.1 Optim@1.11.0 QuantumOptics@1.2.3 PyPlot@2.11.6 IJulia@1.29.0
    ```

---

## Usage

Simulations and analyses can be run through Julia scripts or, for a more interactive experience, through Jupyter Notebooks.

-   **Running Simulation Scripts:**
    Execute Julia scripts from the terminal.
    ```sh
    julia simulations/run_rabi_simulation.jl
    ```
-   **Interactive Analysis with Jupyter:**
    Start a Jupyter Notebook session from your terminal.
    ```sh
    jupyter notebook
    ```
    Then, open a notebook file (e.g., `notebooks/ramsey_analysis.ipynb`) and run the cells.

---

## Future Work

The immediate next steps will focus on expanding the simulation's complexity and realism.

-   **Noise Implementation:** Incorporate shot-to-shot noise to better model experimental uncertainty and variance.
-   **Advanced Protocols:** Progress towards simulating more complex, multi-ion experimental protocols that are relevant to the lab's current research goals.