This is the Verilog implementation of a basic microprocessor.
The model does not include assembly language, so the instructions must be given in binary through a readable text file or in the test bench directly. This is accomplished by adding ports to work with external data. The processor reads instructions from this file after a fixed delay to reduce errors.

It has a 32-bit instruction register divided into subparts for various reasons and functions. All the basic instructions, such as MOV, ADD, and SUB, are included in the processor. 

The processor is built on the Harvard architect with separate storage and signal pathways for instructions and data.

The flow of the processor is made through an FSM, included in the docs.
For more documentation, refer to the 'docs' file.