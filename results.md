# zfs vs ext4 benchmarking results

- Note that a non-local ssd(over the network) was used for each of these benchmarks.
- All benchmarks aren't run on the same machine/drive, but the corresponding zfs/ext4
  benchmarks are run on the same computer/drive.

## Benchstat results
```
name                            ext4 ops/sec  zfs ops/sec  delta
fsbench/create_empty               672 ± 5%    1117 ± 7%   ~     (p=0.100 n=3+3)
fsbench/delete_10k_2MB           5.31k ± 7%   2.42k ±18%   ~     (p=0.100 n=3+3)
fsbench/delete_100k_2MB          30.5k ± 1%    1.8k ± 1%   ~     (p=0.100 n=3+3)
fsbench/delete_10k_2k_200MB        722 ±33%     563 ± 1%   ~     (p=0.700 n=3+3)
fsbench/write_sync_10MB           30.4 ± 3%    27.1 ± 1%   ~     (p=0.100 n=3+3)
fsbench/delete_small_dir_2MB     15.6k ±14%    6.8k ±16%   ~     (p=0.100 n=3+3)
fsbench/delete_small_dir_200MB   18.5k ±25%    1.3k ± 6%   ~     (p=0.100 n=3+3)
fsbench/delete_large_dir_2MB     30.8k ±14%    8.5k ±29%   ~     (p=0.100 n=3+3)
fsbench/delete_large_dir_200MB   22.3k ±12%    6.9k ± 8%   ~     (p=0.100 n=3+3)
```

## Creates

**Benchmark 1:** Creating empty files.
- Name: create_empty
- Methodology:
    1. Create an empty file, sync the parent directory, and measure the latency of the entire create + sync operations.
    2. The benchmark was run for 600 seconds to measure creation times in both small/large directories.
    3. The benchmark was repeated three times on each file system.
    4. The benchmark was run for 600 seconds on each run.
- Results:
1. ext4 results from each run of the benchmark.
```
1.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         386438          644.1      1.6      1.6      2.0      2.5     67.1

2.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         400131          666.9      1.5      1.5      1.9      2.5    335.5

3.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         422736          704.6      1.4      1.4      1.8      2.4    369.1
```
- There was no measurable change in throughput or latencies over the 600 seconds(as directory size grew).
- Around ~360k files were created over 600 seconds.

2. zfs results from each run of the benchmark.
```
1.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         626378         1044.0      1.0      1.0      1.2      1.4     56.6

2.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         664861         1108.1      0.9      0.9      1.1      1.4     88.1

3.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         718886         1198.1      0.8      0.8      1.0      1.8    130.0
```
- There was no measurable change in throughput or latencies over the 600 seconds(as directory size grew).
- Around ~600k files were created over 600 seconds.

Comparison:
- zfs seems to have higher throughput and lower latencies for file creations + sync.

## Delete pre-existing
- Delete pre-existing files

**Benchmark 2:** Create 10k 2MB files, then measure the deletion times of each file.
- Name: delete_10k_2MB
- Methodology:
    1. 10k 2MB files were created outside the timer.
    2. Then deletion performance was measured for each file.
    3. The benchmark was repeated three times on each file system.
    4. The benchmark was run until all 10k files were deleted.
- Results:
1. ext4 results from all three runs of the benchmark.
```
1.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     1.8s          10000         5657.3      0.2      0.2      0.3      0.3      1.5

2.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     2.0s          10000         4988.0      0.2      0.2      0.3      0.4      1.2

3.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     1.9s          10000         5275.4      0.2      0.2      0.3      0.4      1.2
```
- The deletions happen really fast, before the deletion throughput reaches a steady state.
2. zfs results from all three runs of the benchmark.
```
1.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.6s          10000         2770.2      0.4      0.4      0.7      1.1      7.9

2.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     5.0s          10000         1989.1      0.5      0.5      0.7      1.1    100.7

3.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     4.0s          10000         2507.4      0.4      0.4      0.7      0.8      4.1
```
- The deletions happen very fast, before the deletion throughput reaches a steady state.

Comparison:
- Difficult to compare since deletes didn't reach a steady state.

**Benchmark 3:** Create 100k 2MB files, then measure the deletion times of each file.
- Name: delete_100K_2MB
- Methodology:
    1. 100k 2MB files were created outside the timer.
    2. Then deletion performance was measured for each file.
    3. The benchmark was repeated three times on each file system.
    4. The benchmark was run until all 100k files were deleted.
- Results:
1. ext4 results from all three runs of the benchmark.
```
1.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100     3.3s         100000        30400.5      0.0      0.0      0.2      0.3      1.3

2.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100     3.2s         100000        30839.7      0.0      0.0      0.2      0.3      1.3

3.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100     3.3s         100000        30263.3      0.0      0.0      0.2      0.3      1.2
```
- Note that the deletion rate here is much higher than the `delete_10k_2MB` benchmark.
- This is because the benchmark has more time to hit a steady state, although 3 seconds is still too little.

2. zfs results from one run of the benchmark.
```
Running benchmark: delete_100k_2MB
Description: create 100k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100       1s            3.0         2559.9      0.4      0.9      1.1    104.9
delete_100       2s         2100.6         2329.5      0.5      0.7      0.8      5.0
delete_100       3s         1800.7         2152.9      0.5      0.7      0.9     79.7
delete_100       4s         1725.1         2045.7      0.5      0.7      0.8    104.9
delete_100       5s         1866.4         2009.8      0.5      0.7      0.8      5.2
delete_100       6s         1879.6         1988.1      0.5      0.8      0.9      3.7
delete_100       7s         1844.6         1967.6      0.5      0.8      0.9      5.5
delete_100       8s         1880.5         1956.7      0.5      0.7      1.0      5.8
delete_100       9s         1822.4         1941.8      0.6      0.8      0.9      5.5
delete_100      10s         1825.3         1930.1      0.6      0.8      0.9      4.5
delete_100      11s         1811.0         1919.3      0.6      0.8      0.9      5.0
delete_100      12s         1790.1         1908.5      0.6      0.8      0.9      5.2
delete_100      13s         1813.6         1901.2      0.6      0.8      0.9      3.9
delete_100      14s         1824.7         1895.7      0.6      0.8      0.9      4.7
delete_100      15s         1808.7         1889.9      0.6      0.8      0.9      8.9
delete_100      16s         1797.9         1884.2      0.6      0.8      0.9      6.0
delete_100      17s         1823.7         1880.6      0.6      0.8      0.9      3.8
delete_100      18s         1906.5         1882.1      0.5      0.7      0.8      5.5
delete_100      19s         1849.9         1880.4      0.6      0.7      0.9      5.8
delete_100      20s         1895.9         1881.1      0.5      0.7      0.9      6.3
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100      21s         1625.5         1869.0      0.6      0.8      1.0    104.9
delete_100      22s         1695.0         1861.1      0.6      0.8      1.0      5.0
delete_100      23s         1636.5         1851.3      0.6      0.8      0.9      3.9
delete_100      24s         1498.3         1836.6      0.6      0.9      1.0     79.7
delete_100      25s         1618.7         1827.9      0.6      0.8      1.0      3.4
delete_100      26s         1624.0         1820.0      0.6      0.8      1.0      5.5
delete_100      27s         1618.3         1812.6      0.6      0.8      1.0      3.9
delete_100      28s         1620.6         1805.7      0.6      0.8      1.0      3.0
delete_100      29s         1671.3         1801.1      0.6      0.8      0.9      4.5
delete_100      30s         1698.0         1797.6      0.6      0.8      0.9      5.8
delete_100      31s         1657.1         1793.1      0.6      0.8      0.9      5.8
delete_100      32s         1796.7         1793.2      0.6      0.8      0.9      3.3
delete_100      33s         1828.5         1794.3      0.6      0.8      0.9      5.0
delete_100      34s         1836.1         1795.5      0.6      0.8      0.9      3.4
delete_100      35s         1903.8         1798.6      0.5      0.7      0.9      4.7
delete_100      36s         1915.0         1801.8      0.5      0.7      0.9      4.1
delete_100      37s         1867.2         1803.6      0.5      0.7      0.9      3.3
delete_100      38s         1879.6         1805.6      0.5      0.7      0.9      3.9
delete_100      39s         1838.3         1806.4      0.6      0.8      0.9      3.7
delete_100      40s         1820.6         1806.8      0.6      0.8      0.9      4.5
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100      41s         1863.9         1808.2      0.5      0.7      0.9      6.0
delete_100      42s         1824.2         1808.6      0.6      0.8      1.0      4.5
delete_100      43s         1864.1         1809.9      0.5      0.7      0.9      4.5
delete_100      44s         1856.8         1810.9      0.5      0.8      0.9      3.7
delete_100      45s         1819.5         1811.1      0.6      0.8      0.9      2.4
delete_100      46s         1835.3         1811.6      0.6      0.7      0.9      3.9
delete_100      47s         1831.7         1812.1      0.6      0.8      0.9      4.5
delete_100      48s         1834.6         1812.5      0.6      0.8      0.9      5.8
delete_100      49s         1848.5         1813.3      0.5      0.8      0.9      3.5
delete_100      50s         1814.7         1813.3      0.6      0.8      0.9      3.8
delete_100      51s         1820.8         1813.4      0.6      0.8      0.9      3.0
delete_100      52s         1849.5         1814.1      0.5      0.7      0.9      7.3
delete_100      53s         1829.6         1814.4      0.6      0.8      0.9      4.7
delete_100      54s         1724.2         1812.8      0.5      0.7      0.9     79.7
delete_100      55s         1890.0         1814.2      0.5      0.7      0.8      4.1

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100    55.1s         100000         1814.5      0.6      0.6      0.8      0.9    104.9

fsbench/delete_100k_2MB  100000 1814.5 ops/sec
```
- Deletions manage to hit a steady a state, and deletion rate doesn't vary as the directory size
changes from 100k to 0.

Comparison:
- Although, the ext4 benchmark didn't hit a steady state, it managed to delete ~100k files in 3 seconds
compared to 55.1 seconds in the case of zfs. This suggests that deletions on zfs are slower.


**Benchmark 4:** Create 200k 2MB files, then measure the deletion times of each file.
- Name: delete_200K_2MB
- Methodology:
    1. 200k 2MB files were created outside the timer.
    2. Then deletion performance was measured for each file.
    3. This benchmark was only run on ext4, as ext4 deletions didn't hit steady state in the previous benchmarks.
    4. The benchmark was repeated three times.
    5. The benchmark was run until all 200k files were deleted.
- Results:
1. ext4 results from all three runs of the benchmark.
```
1.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200     4.9s         200000        40421.6      0.0      0.0      0.0      0.3      1.2

2.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200     5.0s         200000        39851.7      0.0      0.0      0.0      0.3      5.0

3.
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200     5.2s         200000        38511.9      0.0      0.0      0.0      0.3      5.5
```
- Deletions still happen very fast, and deletion rates become even higher than the previous benchmarks.
- 200k files were deleted in under 6 seconds.
- Although, deletions still didn't hit a steady state, as 200000 finish deleting in ~5s.


## Deletes
- All the benchmarks in this section were run e2e on the same machine(without reformatting the fs b/w runs).
- The benchmark order was, 9, 8, 7, 6.

**Benchmark 6:** Measure deletion times of 2MB files in a small directory.(delete_small_dir_2MB).
- Name: delete_small_dir_2MB
- Methodology:
    1. Start the directory off with 1k 1MB, files, then create/delete 2MB files, while measuring deletion times.
    2. The throughput numbers includes the file creation + file deletion operation, but the latency numbers only
       include the file deletion operation. Average latency can be used to calculate deletion throughput.
    3. The benchmark was repeated three times on each file system.
    4. The benchmark was run for 600 seconds on each run.

- Results:
1. ext4 results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s          40001           66.7 0.05900 0.04096 0.05734 0.06553 75.49747

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.1s          34865           58.1 0.07445 0.03277 0.05734 0.06553 96.46899

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.1s          33461           55.8 0.06068 0.03277 0.05734 0.06553 75.49747
```


2. zfs results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s          58766           97.9 0.17491 0.07373 0.13107 0.21299 79.69178

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s          48210           80.3 0.13797 0.08192 0.13926 0.18022 83.88608

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.1s          45617           76.0 0.13496 0.08192 0.13926 0.18841 83.88608
```

Comparison:
- Deletes on ext4 are faster.

**Benchmark 7:** Measure deletion times of 200MB files in a small directory.
- Name: delete_small_dir_200MB
- Methodology:
    1. Start the directory off with 1k 1MB, files, then create/delete 200MB files, while measuring deletion times.
    2. The throughput numbers includes the file creation + file deletion operation, but the latency numbers only
       include the file deletion operation. Deletion throughput can be calculated using average latencies.
    3. The benchmark was repeated three times on each file system.
    4. The benchmark was run for 600 seconds on each run.
- Results:
1. ext4 results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s            628            1.0 0.07221 0.04915 0.07373 0.09011 13.10720

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s            630            1.0 0.04897 0.04915 0.05734 0.07373 0.11469

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s            625            1.0 0.04735 0.04915 0.05734 0.07373 0.12288
```


2. zfs results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s            584            1.0 0.82262 0.78643 2.22822 4.45645 10.48576

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.0s            564            0.9 0.73689 0.75366 1.63840 3.93216 11.01005

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_sma   600.1s            569            0.9 0.76986 0.75366 1.50733 3.27680 8.91290
```
- These zfs results seemed a bit extreme, so I reformatted the file system on the same machine
  and ran this benchmark again, and got latencies in the ~0.4ms range.

Comparison:
- Deletes on ext4 are faster. There is an order of magnitude latency difference between ext4 and zfs.

**Benchmark 8:** Measure deletion times of 2MB files in a large directory.
- Name: delete_large_dir_2MB
- Methodology:
    1. Start the directory off with 100k 1MB, files, then create/delete 2MB files, while measuring deletion times.
    2. The throughput numbers includes the file creation + file deletion operation, but the latency numbers only
       include the file deletion operation. Deletion throughput can be calculated using average latencies.
    3. The benchmark was repeated three times on each file system.
    4. The benchmark was run for 600 seconds on each run.
- Results:
1. ext4 results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s          73731          122.9 0.02843 0.03277 0.04915 0.06553 5.76717

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s          60304          100.5 0.03307 0.03277 0.04915 0.05734 20.97152

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.1s          58548           97.6 0.03700 0.03277 0.04915 0.05734 35.65158
```
Notes
- Suprisingly, these deletes are much faster than deleting 2MB files in a small directory. I ran this again on

2. zfs results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s          70632          117.7 0.09066 0.08192 0.14746 0.45875 11.53434

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s          70539          117.6 0.12892 0.08192 0.13107 0.49152 37.74873

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s          70230          117.0 0.14590 0.08192 0.13926 0.47514 56.62310
```

Comparison:
- Deletes on ext4 are faster. We might need to run the benchmarks while printing out the latencies in nanoseconds
  to see a more precise comparison. But from the previous deletion benchmarks, we already know that deletion
  throughput is much higher on ext4.

**Benchmark 9:** Measure deletion times of 200MB files in a large directory.
- Name: delete_large_dir_200MB
- Methodology:
    1. Start the directory off with 100k 1MB, files, then create/delete 200MB files, while measuring deletion times.
    2. The throughput numbers includes the file creation + file deletion operation, but the latency numbers only
       include the file deletion operation. Deletion throughput can be calculated using average latencies.
    3. The benchmark was repeated three times on each file system.
- Results:
1. ext4 results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s            708            1.2 0.04950 0.04915 0.06553 0.09830 0.18841

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s            704            1.2 0.04030 0.04096 0.05734 0.07373 0.09830

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s            676            1.1 0.04760 0.04915 0.05734 0.09830 0.11469
```


2. zfs results from each of the three runs of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s            605            1.0 0.15884 0.15565 0.25395 0.31129 1.04858

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s            609            1.0 0.13552 0.13107 0.22118 0.27853 0.32768

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_lar   600.0s            613            1.0 0.14488 0.13926 0.22118 0.27853 2.49037
```

Comparison:


**Benchmark 10:** Write 10MB to a file and then call sync.
- Name: write_sync_10MB
- Methodology:
    1. We write 10MB to a file, then call sync, measuring latencies for the sync.
    2. A new file is created once the old file hits 2GB.
    3. The benchmark was run for 600 seconds on each run.
    4. Note that the throughput numbers in the benchmark aren't accurate, since
       the throughput column is measuring the throughput of the entire (file write + sync) operation.
       However, the latency numbers, measure only the latency of the sync and are accurate. The average
       latency numbers can be used to calculate the average throughput.
    5. The benchmark ws run thrice on each file system.
- Results:
1. ext4 results from each run of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
write_sync   600.0s          15058           25.1     32.5     33.6     35.7     35.7     39.8

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
write_sync   600.0s          15057           25.1     32.1     32.5     35.7     35.7     54.5

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
write_sync   600.0s          15057           25.1     30.4     31.5     32.5     33.6     54.5
```
- Note that sync latencies don't vary much over the 600s.

3. zfs results from each run of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
write_sync   600.0s          14625           24.4     37.3     37.7     44.0     50.3     83.9

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
write_sync   600.0s          14536           24.2     36.5     37.7     44.0     50.3    109.1

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
write_sync   600.0s          14587           24.3     36.9     37.7     44.0     50.3    104.9
```
- Note that sync latencies don't vary much over the 600s.

Comparison:
- The latencies are similar, which suggests that both file systems have similar sync performance
  for 10MB files. Although, the average latencies for ext4 is slightly lower.
- This is in contrast with zfs having much faster file create + sync.


Notes:
- This benchmark was also run with 1MB, 100MB, and we saw the throughputs/latencies scale linearly.
For example, for 1MB files, sync latencies were 2-3ms, compared to 20-30ms for 10MB files, and 200-300ms
for 100MB files.


**Benchmark 11:** statfs with many files.
- Name: statfs_many_files
- Methodology:
    1. statfs was called on the parent directory after creation + 100KB writes on a file.
    3. The benchmark was run for 600 seconds on each run.
    4. Note that the throughput numbers in the benchmark aren't accurate, since
       the throughput column is measuring the throughput of the entire (file create/write + statfs) operation.
       However, the latency numbers, measure only the latency of the statfs call and are accurate. The average
       latency numbers can be used to calculate the average throughput.
    5. The benchmark was run thrice on each file system.
- Results:
1. ext4 results from each of the runs.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
statfs_man   600.0s         294723          491.2      0.0      0.0      0.0      0.0      0.1

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
statfs_man   600.0s         285925          476.5      0.0      0.0      0.0      0.0      0.1

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
statfs_man   600.0s         290498          484.2      0.0      0.0      0.0      0.0      0.4
```
- Note that sync latencies don't vary much over the 600s.

2. zfs results from each of the runs.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
statfs_man   600.0s         601088         1001.8      0.0      0.0      0.0      0.0     14.2

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
statfs_man   600.0s         598059          996.8      0.0      0.0      0.0      0.0     18.9

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
statfs_man   600.0s         576686          961.1      0.0      0.0      0.0      0.0     11.0
```

Comparison:
- Over 600 seconds, the ext4 benchmark created ~300k files, and the zfs benchmark created ~600k files.
- Each file was 100KB.
- But the statfs operation still returned extremely quickly, and probably has a O(1) runtime even as
  the number files in a directory increase.

Notes:
- A similar statfs benchmark was run with 100MB files, and there was no difference in statfs performance.
