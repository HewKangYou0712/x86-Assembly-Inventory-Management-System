# x86 Assembly Inventory Management System

A low-level system utility developed to manage warehouse inventory and user authentication through direct interaction with the Linux kernel via system calls.

## 🔬 Project Overview
This project demonstrates the efficiency of low-level programming by implementing a fully functional management system in x86 Assembly. By bypassing high-level runtimes, the system achieves a near-zero memory footprint and maximum execution speed, handling complex tasks like file I/O and string manipulation at the register level.

## 🛠 Tech Stack & Environment
* **Language:** x86 Assembly (Intel Syntax)
* **Assembler:** NASM (Netwide Assembler)
* **Linker:** LD (GNU Linker)
* **Platform:** Linux (elf_i386 architecture)
* **Interface:** Command Line (CLI)

## 🏗️ Technical Implementation Details

### 1. Direct Kernel Interaction
The system utilizes **Linux System Calls (int 0x80)** for all core operations, including:
* **File Operations:** `SYS_OPEN`, `SYS_READ`, `SYS_WRITE`, and `SYS_CLOSE` for persistent data storage in `.txt` files.
* **Process Control:** `SYS_EXIT` for clean resource deallocation.

### 2. Low-Level Logic & Architecture
* **Memory Management:** Manual handling of data buffers and pointers without a heap manager.
* **Register Optimization:** Strategic use of General Purpose Registers (EAX, EBX, ECX, EDX) for high-speed arithmetic and comparison logic.
* **Custom Procedures:** Implementation of manual stack-based procedures for modular logic, including string length calculation and input validation.

### 3. Features
* **Role-Based Access Control:** Secure login system distinguishing between Admin and Inventory Checker roles.
* **CRUD Operations:** Manual implementation of adding, deleting, and updating inventory records via direct file buffer manipulation.
* **Error Handling:** Register-level validation for incorrect credentials and unauthorized system access.

## 📊 Key Highlights
* **Zero Dependencies:** Does not rely on the C Standard Library (libc).
* **Deterministic Performance:** Execution speed is limited only by hardware and kernel interrupt latency.
* **Data Persistence:** Implements a custom file parsing logic to manage `userdata.txt` and `inventory.txt`.

## 📜 Compilation & Usage
To assemble and link the project on a Linux system:

1. **Assemble:** `nasm -f elf32 TP073666.asm -o TP073666.o`
2. **Link:** `ld -m elf_i386 TP073666.o -o TP073666`
3. **Run:** `./TP073666`

## 📸 System Demo
<img width="463" height="417" alt="image" src="https://github.com/user-attachments/assets/728b04d6-8b43-4237-baf1-0e6f09400340" />
