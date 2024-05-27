# LMS_RLS_Adaptive_FIlters
This repository contains Verilog HDL code for the implementation of two adaptive filters: the Least Mean Squares (LMS) filter and the Recursive Least Squares (RLS) filter. The repository also includes a comparison of their performance.

## Overview

Adaptive filters are essential components in digital signal processing systems, enabling real-time adjustment of filter coefficients to adapt to changing input signals. They are widely used in applications such as noise cancellation, echo cancellation, and system identification. The LMS and RLS algorithms are popular choices for adaptive filtering due to their simplicity and effectiveness.

## Theory

### Least Mean Squares (LMS) Filter

The LMS algorithm is a stochastic gradient-based method used for adaptive filtering. It iteratively adjusts the filter coefficients to minimize the mean squared error between the desired signal and the filter output. At each iteration, the filter coefficients are updated using the following formula:

$$
w(n+1) = w(n) + \mu e(n) x(n)
$$

where:
- \(w(n)\) is the vector of filter coefficients at time \(n\).
- \(\mu\) is the step size or adaptation rate.
- \(e(n)\) is the error signal, calculated as the difference between the desired signal and the filter output at time \(n\).
- \(x(n)\) is the input signal vector at time \(n\).

The LMS algorithm is computationally simple and suitable for online adaptation, making it well-suited for applications with real-time processing requirements. However, it may exhibit slow convergence and sensitivity to the choice of the adaptation rate parameter.

### Recursive Least Squares (RLS) Filter

The RLS algorithm is a recursive method used for adaptive filtering. It computes the filter coefficients recursively based on past input and output data, providing a computationally efficient solution for adaptive filtering tasks. The RLS algorithm minimizes the weighted sum of squared errors over a finite time window. The filter coefficients are updated using the following equations:

$$
P(n+1) = \frac{1}{\lambda} [P(n) - \frac{P(n) x(n) x^T(n) P(n)}{\lambda + x^T(n) P(n) x(n)}]
$$

$$
w(n+1) = w(n) + P(n+1) x(n) e(n)
$$

where:
- \(P(n)\) is the inverse correlation matrix at time \(n\).
- \(\lambda\) is the forgetting factor, controlling the influence of past data on the current estimate.
- \(e(n)\) is the error signal, calculated as the difference between the desired signal and the filter output at time \(n\).
- \(x(n)\) is the input signal vector at time \(n\).

The RLS algorithm offers fast convergence and robustness to parameter selection, making it suitable for applications requiring high performance and accuracy. However, it may exhibit higher computational complexity and memory requirements compared to the LMS algorithm.

## Implementation

### LMS Filter

The Verilog implementation of the LMS filter includes modules for filter adaptation and coefficient updating. It provides a practical demonstration of the LMS algorithm's functionality in hardware.

### RLS Filter

The Verilog implementation of the RLS filter includes modules for matrix inversion and coefficient updating. It demonstrates the recursive nature of the RLS algorithm and its efficient implementation in hardware.

## Performance Comparison

The repository includes performance evaluation of the LMS and RLS filters in terms of convergence speed, steady-state error, and computational complexity. The comparison is based on simulations using test vectors and synthetic input signals.

## Usage

To use the Verilog code:

1. Clone this repository to your local machine
2. Open the Verilog files in a Verilog simulator or synthesis tool of your choice.

3. Simulate the Verilog design to observe the performance of the LMS and RLS filters under different conditions.

4. Analyze the simulation results and compare the performance metrics of the two adaptive filters.

## Conclusion

The Verilog implementations of the LMS and RLS adaptive filters provide a practical demonstration of their functionality and performance characteristics. The comparison highlights the trade-offs between convergence speed, steady-state error, and computational complexity, aiding in the selection of the appropriate adaptive filter for specific signal processing tasks.

## License

This project is licensed under the  Apache License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

This implementation is part of the course project for the EE5516 VLSI Architectures for Signal Processing and Machine Learning course.
