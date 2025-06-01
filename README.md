# UART-TX-RX
UART Transmitter and Receiver designed in Verilog, verified in SystemVerilog and UVM.

---
## About
- Transmitter and Reciever are independent and can be used for separate operations.
- Clock frequency and Baud rate are parameters in 'uart_top' which can be modified.
- Receiver consists of a datapath and a control unit while transmitter is one module.
- In 'uart_top' module 'uart_rx' and 'uart_tx' are bith connected to 'baud_generator'.
- Testbench files are in 'uart_tb_sv' and 'uart_tb_uvm' folders. (Both include 'uart_pkg' packages
with all of the classes included: driver, monitor, scoreboard etc.)

---
## Schematic
<div align="center"> <img src="/uart_design/schematic.png"> </div>

---
## Simulation Screenshots
SystemVerilog Simulation
<div align="center"> <img src="/uart_simulation_results/sv_tb_results/sv_vivado_waveforms.png"> </div>

UVM Simulation
<div align="center"> <img src="/uart_simulation_results/uvm_tb_results/uvm_eda_waveforms.png"> </div> 

---
## Console Info
- Console outputs from Vivado Simulator (for SV simulation) and EDA Playground (for UVM simulation)
are included in 'uart_simulation_results' file.
