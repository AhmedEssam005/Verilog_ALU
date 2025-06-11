# Arithmetic Logic Unit on FPGA

### CMP101 Project – Fall 2024

## Introduction

This project involves designing and implementing an **Arithmetic Logic Unit (ALU)** using **Verilog HDL** for the **Intel DE1-SoC FPGA Board**. The ALU evaluates mathematical expressions that include **five signed single-digit numbers** and **four binary operations** (`+`, `-`, `*`, `/`). Input is provided using hardware switches, and output is displayed via seven-segment displays and indicator LEDs.

## Key Features

- **Input Handling**:

  - Numbers: 2-bit signed values (0–3).
  - Sign: 1-bit flag (positive = 1, negative = 0).
  - Operations: 2-bit encoding representing `+`, `-`, `*`, `/`.
  - Clock: Simulated using a pushbutton to capture each input.

- **Operations**:

  - **Addition/Subtraction**: Constructed using custom Half Adder and Full Adder modules.
  - **Multiplication**: Implemented with bitwise shifting and addition.
  - **Division**: Performed using a restoring division method.

- **Display**:

  - Results are displayed in BCD format across three seven-segment displays.
  - Current input is shown on a separate display.
  - Status indicators (LEDs) show negative results, division-by-zero, and zero output.

- **Error Detection**:

  - Division by zero displays 0 and lights a dedicated LED.
  - Result equals zero triggers the zero indicator LED.
  - Negative results activate the sign LED.

## Module Descriptions

| Module Name                | Function                                                                |
| -------------------------- | ----------------------------------------------------------------------- |
| `HADD`, `FADD`             | Basic Half Adder and Full Adder components for binary arithmetic        |
| `ToEightBitExtender`       | Expands input to 8 bits with sign extension and two's complement logic  |
| `OperatorPlus`             | Adds two signed values                                                  |
| `OperatorMinus`            | Subtracts two values using additive inversion                           |
| `OperatorMultiply`         | Multiplies inputs using shift-and-add                                   |
| `OperatorDivision`         | Divides values and handles divide-by-zero cases                         |
| `Manager`                  | Coordinates inputs, operations, and result tracking                     |
| `binary_to_bcd`            | Converts binary result to BCD for display                               |
| `seven_segment`            | Displays digits on seven-segment outputs                                |
| `seven_segment_Sign`       | Displays sign indication on the segment                                 |
| `seven_segment_controller` | Controls layout of all display segments                                 |
| `Calculator`               | Top-level control unit that sequences input and connects all submodules |

## Simulation and Testing

### Simulation

Use tools such as **ModelSim** or **Quartus** to:

- Verify functionality of arithmetic logic.
- Confirm correct sequencing and display logic.
- Test edge cases, including invalid operations.

### FPGA Deployment

- Deploy the project to the **DE1-SoC FPGA Board**.
- Use these controls:
  - `SW[1:0]`: Input number
  - `SW[2]`: Sign flag
  - `SW[5:4]`: Operation code
  - `KEY[0]`: Clock simulation
- Observe:
  - Seven-segment displays for current input and results
  - LEDs for negative result, zero, and divide-by-zero indicators

## Team Information

- Project by a team of 3–4 students
- Course: **CMP101 – Logic Design**
- Institution: **Cairo University, Faculty of Engineering**

## File Structure

```
.
├── Calculator.v             # Top-level design controller
├── Manager.v                # Central module for managing operations
├── ArithmeticModules.v      # All arithmetic logic (Add, Sub, Mul, Div)
├── DisplayModules.v         # Modules related to display logic
├── UtilityModules.v         # Support modules (adders, bit extension)
├── README.md                # Project documentation
├── Simulation files         # Testbenches and waveforms
└── Logic Design Project.pdf # Project description from the course
```

