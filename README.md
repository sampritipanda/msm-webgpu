# msm-webgpu

This repository contains an implementation of elliptic curve cryptography algorithms using WebGPU for parallel processing. The primary focus is on the efficient computation of scalar multiplication on elliptic curves using the Pippenger algorithm, which is beneficial for cryptographic applications such as blockchain, secure communication, and digital signatures.

## Repository Structure

- `main.wgsl`: The main WebGPU shader that orchestrates the computation.
- `pippenger.wgsl`: Implements the Pippenger algorithm for scalar multiplication on elliptic curves.
- `curve.wgsl`: Contains functions for elliptic curve operations in Jacobian coordinates.
- `field.wgsl`: Implements arithmetic in a finite field, necessary for elliptic curve operations.
- `*.wgsl`: Other WGSL files provide additional cryptographic utilities and operations.

## How to Use

To use this repository, ensure you have a WebGPU-enabled environment. You can then utilize the provided WGSL shaders in your application to perform high-performance cryptographic operations.

1. Clone the repository.
2. Integrate the WGSL shaders with your WebGPU setup.
3. Invoke the shaders to perform cryptographic computations as required by your application.

## Contributing

Contributions to this repository are welcome. Please ensure to follow the existing code structure and maintain the coding conventions used throughout the shaders.

## License

This project is licensed under the [MIT License](LICENSE).
