These are fake modules used to maintain the structure of the core files and only used by Verilator for simulation.

- HPS_IO is completely fake but ports are public and exposed to the testbench file.
- PLL module is used for clock generation.
- The video_cleaner is fake and just reassigns inputs to outputs.
- dpram was converted to a simple ram module.
