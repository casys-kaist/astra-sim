Regression Test Specifications

BINARY:
    Analytical congestion-aware and congestion-unaware backends.
INPUTS:
    WORKLOAD:
        Four ranks execute one all-reduce followed by a rank-local compute
        tail. Rank 1's tail is deliberately slower than ranks 0, 2, and 3.
    SYSTEM:
        Ring all-reduce with duration replay enabled.
    NETWORK:
        One-dimensional ring of four NPUs.
    MEMORY:
        No remote memory expansion.
VALIDATION:
    Rank 0 may report as soon as its local graph finishes. Rank 3 is the
    instance completion rank and must not report until the slower middle rank
    has completed the same iteration. The test verifies that rank 3's report
    time is later than rank 0's and that no rank remains at shutdown.
