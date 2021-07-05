**zfs vs ext4 benchmarking results**

- Note that a non-local ssd(over the network) was used for each of these benchmarks.
- The benchmarks were run on the same computer/drive.

**Benchmark 1:** Creating empty files(create_empty).
- Methodology:
    1. Create an empty file, sync the parent directory, and measure the latency of the entire create + sync operations.
    2. The benchmark was run for 600 seconds to measure creation times in both small/large directories.
    3. The benchmark was repeated three times on each file system.
- Results:
1. ext4 results from each run of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         386438          644.1      1.6      1.6      2.0      2.5     67.1

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         400131          666.9      1.5      1.5      1.9      2.5    335.5

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         422736          704.6      1.4      1.4      1.8      2.4    369.1
```
- There was no measurable change in throughput or latencies over the 600 seconds.
- Around ~360k files were created over 600 seconds.

2. zfs results from each run of the benchmark.
```
____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         626378         1044.0      1.0      1.0      1.2      1.4     56.6

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         664861         1108.1      0.9      0.9      1.1      1.4     88.1

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
create_emp   600.0s         718886         1198.1      0.8      0.8      1.0      1.8    130.0
```
- There was no measurable change in throughput or latencies over the 600 seconds.
- Around ~600k files were created over 600 seconds.

Comparison:
- zfs seems to have higher throughput and lower latencies for file creations + sync.
- The benchmark was repeated thrice on each file system.

**Benchmark 2:** Create 10k 2MB files, then measure the deletion times of each file(delete_10k_2MB).
- Methodology:
    1. 10k 2MB files were created outside the timer.
    2. Then deletion performance was measured for each file.
- Results:
1. ext4 results from all three runs of the benchmark.
```
Running benchmark: delete_10k_2MB
Description: create 10k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s           49.8         4082.4      0.2      0.3      0.4      1.5

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     1.8s          10000         5657.3      0.2      0.2      0.3      0.3      1.5

fsbench/delete_10k_2MB  10000 5657.3 ops/sec

Running benchmark: delete_10k_2MB
Description: create 10k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s           44.6         3677.1      0.3      0.3      0.4      1.2
delete_10k       2s         6060.8         4868.2      0.2      0.3      0.4      0.7

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     2.0s          10000         4988.0      0.2      0.2      0.3      0.4      1.2

fsbench/delete_10k_2MB  10000 4988.0 ops/sec

Running benchmark: delete_10k_2MB
Description: create 10k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s           46.0         3791.1      0.3      0.3      0.4      1.2

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     1.9s          10000         5275.4      0.2      0.2      0.3      0.4      1.2

fsbench/delete_10k_2MB  10000 5275.4 ops/sec
```
- The deletions happen really fast, before the deletion throughput reaches a steady state.
2. zfs results from all three runs of the benchmark.
```
Running benchmark: delete_10k_2MB
Description: create 10k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s           56.7         4870.2      0.1      0.5      0.7      6.0
delete_10k       2s         2083.0         3472.1      0.4      0.7      1.5      7.9
delete_10k       3s         1926.7         2956.2      0.5      0.7      1.5      4.7

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.6s          10000         2770.2      0.4      0.4      0.7      1.1      7.9

fsbench/delete_10k_2MB  10000 2770.2 ops/sec

Running benchmark: delete_10k_2MB
Description: create 10k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s           27.4         2338.6      0.4      0.6      1.4    100.7
delete_10k       2s         1914.5         2126.6      0.5      0.7      1.6      5.0
delete_10k       3s         1862.0         2038.4      0.5      0.8      1.0      2.9
delete_10k       4s         1905.5         2005.2      0.5      0.7      0.9      3.0
delete_10k       5s         1925.6         1989.3      0.5      0.7      0.9      5.0

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     5.0s          10000         1989.1      0.5      0.5      0.7      1.1    100.7

fsbench/delete_10k_2MB  10000 1989.1 ops/sec

Running benchmark: delete_10k_2MB
Description: create 10k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s           47.0         4012.3      0.1      0.6      0.7      3.4
delete_10k       2s         2110.7         3061.2      0.5      0.7      0.8      3.8
delete_10k       3s         1965.8         2696.3      0.5      0.7      0.9      2.4

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     4.0s          10000         2507.4      0.4      0.4      0.7      0.8      4.1

fsbench/delete_10k_2MB  10000 2507.4 ops/sec
```
- The deletions happen very fast, before the deletion throughput reaches a steady state.

Comparison:
- Difficult to compare since deletes didn't reach a steady state.

**Benchmark 3:** Create 100k 2MB files, then measure the deletion times of each file(delete_100K_2MB).
- Methodology:
    1. 100k 2MB files were created outside the timer.
    2. Then deletion performance was measured for each file.
- Results:
1. ext4 results from all three runs of the benchmark.
```
Running benchmark: delete_100k_2MB
Description: create 100k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100       1s            4.8         3934.9      0.3      0.3      0.4      1.3
delete_100       2s        11192.7         7564.8      0.0      0.3      0.3      0.9
delete_100       3s        65339.3        26824.1      0.0      0.0      0.0      0.4

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100     3.3s         100000        30400.5      0.0      0.0      0.2      0.3      1.3

fsbench/delete_100k_2MB  100000 30400.5 ops/sec


Running benchmark: delete_100k_2MB
Description: create 100k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100       1s            4.9         3965.5      0.3      0.3      0.4      1.3
delete_100       2s        13960.3         8962.3      0.0      0.3      0.3      0.5
delete_100       3s        64925.6        27613.0      0.0      0.0      0.0      0.3

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100     3.2s         100000        30839.7      0.0      0.0      0.2      0.3      1.3

fsbench/delete_100k_2MB  100000 30839.7 ops/sec


Running benchmark: delete_100k_2MB
Description: create 100k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100       1s            4.7         3855.4      0.3      0.3      0.4      1.2
delete_100       2s        10006.7         6929.6      0.0      0.3      0.4      0.6
delete_100       3s        64538.3        26131.6      0.0      0.0      0.0      0.3

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_100     3.3s         100000        30263.3      0.0      0.0      0.2      0.3      1.2

fsbench/delete_100k_2MB  100000 30263.3 ops/sec
```
- Note that the deletion rate here is much higher than the deletion rate with only 10k 2MB files.
- This is because the benchmark has more time to hit a steady state, although 3 seconds is still too little.

2. zfs results from one run of the benchmark(the other runs were similar).
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


**Benchmark 4:** Create 200k 2MB files, then measure the deletion times of each file(delete_200K_2MB).
- Methodology:
    1. 200k 2MB files were created outside the timer.
    2. Then deletion performance was measured for each file.
    3. This benchmark was only run on ext4, as ext4 deletions didn't hit steady state in the previous benchmarks.
- Results:
1. ext4 results from all three runs of the benchmark.
```
Running benchmark: delete_200k_2MB
Description: create 200k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200       1s            2.3         3788.6      0.3      0.3      0.4      1.2
delete_200       2s         9670.8         6729.1      0.0      0.3      0.3      0.7
delete_200       3s        60005.0        24484.1      0.0      0.0      0.0      0.3
delete_200       4s        63186.7        34159.4      0.0      0.0      0.0      0.6

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200     4.9s         200000        40421.6      0.0      0.0      0.0      0.3      1.2

fsbench/delete_200k_2MB  200000 40421.6 ops/sec


Running benchmark: delete_200k_2MB
Description: create 200k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200       1s            2.3         3772.5      0.3      0.3      0.4      0.5
delete_200       2s         9953.2         6862.1      0.0      0.3      0.3      0.6
delete_200       3s        57822.6        23844.6      0.0      0.0      0.0      2.8
delete_200       4s        62177.3        33424.9      0.0      0.0      0.0      1.6
delete_200       5s        65554.6        39856.2      0.0      0.0      0.0      5.0

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200     5.0s         200000        39851.7      0.0      0.0      0.0      0.3      5.0

fsbench/delete_200k_2MB  200000 39851.7 ops/sec


Running benchmark: delete_200k_2MB
Description: create 200k 2MB size files, measure deletion times
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200       1s            2.3         3721.2      0.3      0.3      0.4      1.3
delete_200       2s         3300.7         3511.0      0.3      0.4      0.4      0.5
delete_200       3s        52281.3        19759.1      0.0      0.0      0.1      0.7
delete_200       4s        63075.3        30592.6      0.0      0.0      0.0      1.6
delete_200       5s        65038.9        37480.3      0.0      0.0      0.0      5.5

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_200     5.2s         200000        38511.9      0.0      0.0      0.0      0.3      5.5

fsbench/delete_200k_2MB  200000 38511.9 ops/sec
```
- Deletions still happen very fast, and deletion rates become even higher than the previous benchmarks.
- 200k files were deleted in under 6 seconds.


**Benchmark 5:** Create 100k 2MB files, then measure the deletion times of each file(delete_10k_2k_200MB).
- Methodology:
    1. 8k 2MB, and 2k 200 MB files were created.
    2. Then deletion performance was measured for each of the 2k 200MB files.
    3. Note that 2000 2MB files is already 400GB of data.
- Results:
1. ext4 results from all three runs of the benchmark.
```
Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            1.0         1644.4      0.0      3.9      4.2     10.5
delete_10k       2s          254.0          949.3      3.8      4.1      8.4     13.6
delete_10k       3s           68.0          655.6     23.1     25.2     25.2     25.2

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.8s           2000          529.4      1.9      0.0      4.2     24.1     25.2

fsbench/delete_10k_2k_200MB  2000 529.4 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            1.1         1953.6      0.0      3.8     24.1     27.3
delete_10k       2s           41.0          998.0     24.1     25.2     27.3     27.3

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     2.1s           2000          963.2      1.0      0.0      3.9     24.1     27.3

fsbench/delete_10k_2k_200MB  2000 963.2 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            1.0         1677.0      0.0      0.0      0.1    436.2
delete_10k       2s          278.0          977.4      0.0      0.0      0.1   1476.4

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.0s           2000          672.9      1.5      0.0      0.0     24.1   1476.4

fsbench/delete_10k_2k_200MB  2000 672.9 ops/sec
```
- The 2000 200MB files get deleted before the deletion throughput hits a steady state. 2000 files
  get deleted in under 3 seconds.

2. zfs results from all three runs of the benchmark.
```
Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            0.3          685.8      1.3      2.5      5.0      9.4
delete_10k       2s          571.1          628.2      1.4      2.5      6.3    159.4
delete_10k       3s          519.9          592.1      1.3      2.5      5.5    268.4

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.6s           2000          558.7      1.8      1.3      2.5      5.8    285.2

fsbench/delete_10k_2k_200MB  2000 558.7 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            0.4          741.4      1.2      2.0      5.5      6.8
delete_10k       2s          579.2          660.3      1.2      2.2      4.7    234.9
delete_10k       3s          483.4          601.5      1.2      2.0      3.4    318.8

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.5s           2000          570.3      1.8      1.2      2.2      5.0    318.8

fsbench/delete_10k_2k_200MB  2000 570.3 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            0.4          738.4      1.2      1.7      5.8     10.0
delete_10k       2s          562.5          650.5      1.2      1.6      3.1    285.2
delete_10k       3s          503.0          601.3      1.3      1.6      3.7    335.5

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.6s           2000          559.4      1.8      1.2      1.7      4.7    335.5

fsbench/delete_10k_2k_200MB  2000 559.4 ops/sec
```
- Deletions don't hit steady state.

Comparison:
- Both benchmarks seem to be unaffected by file size at least when there are only 10k files in the
directory.

**Benchmark 5:** Create 100k 2MB files, then measure the deletion times of each file(delete_10k_2k_200MB).
- Methodology:
    1. 8k 2MB, and 2k 200 MB files were created.
    2. Then deletion performance was measured for each of the 2k 200MB files.
    3. Note that 2000 2MB files is already 400GB of data.
- Results:
1. ext4 results from all three runs of the benchmark.
```
Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            1.0         1644.4      0.0      3.9      4.2     10.5
delete_10k       2s          254.0          949.3      3.8      4.1      8.4     13.6
delete_10k       3s           68.0          655.6     23.1     25.2     25.2     25.2

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.8s           2000          529.4      1.9      0.0      4.2     24.1     25.2

fsbench/delete_10k_2k_200MB  2000 529.4 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            1.1         1953.6      0.0      3.8     24.1     27.3
delete_10k       2s           41.0          998.0     24.1     25.2     27.3     27.3

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     2.1s           2000          963.2      1.0      0.0      3.9     24.1     27.3

fsbench/delete_10k_2k_200MB  2000 963.2 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            1.0         1677.0      0.0      0.0      0.1    436.2
delete_10k       2s          278.0          977.4      0.0      0.0      0.1   1476.4

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.0s           2000          672.9      1.5      0.0      0.0     24.1   1476.4

fsbench/delete_10k_2k_200MB  2000 672.9 ops/sec
```
- The 2000 200MB files get deleted before the deletion throughput hits a steady state. 2000 files
  get deleted in under 3 seconds.

2. zfs results from all three runs of the benchmark.
```
Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            0.3          685.8      1.3      2.5      5.0      9.4
delete_10k       2s          571.1          628.2      1.4      2.5      6.3    159.4
delete_10k       3s          519.9          592.1      1.3      2.5      5.5    268.4

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.6s           2000          558.7      1.8      1.3      2.5      5.8    285.2

fsbench/delete_10k_2k_200MB  2000 558.7 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            0.4          741.4      1.2      2.0      5.5      6.8
delete_10k       2s          579.2          660.3      1.2      2.2      4.7    234.9
delete_10k       3s          483.4          601.5      1.2      2.0      3.4    318.8

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.5s           2000          570.3      1.8      1.2      2.2      5.0    318.8

fsbench/delete_10k_2k_200MB  2000 570.3 ops/sec


Running benchmark: delete_10k_2k_200MB
Description: create 10k files, with 2k 200MB files, measure deletion times of 200MB files
____optype__elapsed__ops/sec(inst)___ops/sec(cum)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k       1s            0.4          738.4      1.2      1.7      5.8     10.0
delete_10k       2s          562.5          650.5      1.2      1.6      3.1    285.2
delete_10k       3s          503.0          601.3      1.3      1.6      3.7    335.5

____optype__elapsed_____ops(total)___ops/sec(cum)__avg(ms)__p50(ms)__p95(ms)__p99(ms)_pMax(ms)
delete_10k     3.6s           2000          559.4      1.8      1.2      1.7      4.7    335.5

fsbench/delete_10k_2k_200MB  2000 559.4 ops/sec
```
- Deletions don't hit steady state.

Comparison:
- Both benchmarks seem to be unaffected by file size at least when there are only 10k files in the
directory.


**Benchmark 6:** Write 10MB to a file and then call sync(write_sync_10MB).
- Methodology:
    1. We write 10MB to a file, then call sync, measuring latencies for the sync.
    2. A new file is created once the old file hits 2GB.
    3. The benchmark was run for 600 seconds.
    4. Note that the throughput numbers in the benchmark aren't accurate, since
       the throughput column is measuring the throughput of the entire (file write + sync) operation.
       However, the latency numbers, measure only the latency of the sync and are accurate. The average
       latency numbers can be used to calculate the average throughput.
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
For example, for 1MB files, sync latencies were 2-3ms.


**Benchmark 7:** statfs with many files(statfs_many_files).
- Methodology:
    1. statfs was called on the parent directory after creation + 100KB writes on a file.
    3. The benchmark was run for 600 seconds.
    4. Note that the throughput numbers in the benchmark aren't accurate, since
       the throughput column is measuring the throughput of the entire (file create/write + statfs) operation.
       However, the latency numbers, measure only the latency of the statfs call and are accurate. The average
       latency numbers can be used to calculate the average throughput.
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
- But the statfs operation still returned extremely quickly.

Notes:
- A similar statfs benchmark was run with 100MB files, and there was no difference in statfs performance.


**benchstat comparison**
1. For the `write_sync_10MB` benchmark, the throughput numbers were calculated using average latency.
2. Results from statfs benchmarks aren't included here, because the average latency was 0 for both ext4 and zfs,
    and the throughput numbers are inaccurate as in the `write_sync` benchmark.
```
name                         old ops/sec  new ops/sec  delta
fsbench/create_empty            672 ± 5%    1117 ± 7%   ~     (p=0.100 n=3+3)
fsbench/delete_10k_2MB        5.31k ± 7%   2.42k ±18%   ~     (p=0.100 n=3+3)
fsbench/delete_100k_2MB       30.5k ± 1%    1.8k ± 1%   ~     (p=0.100 n=3+3)
fsbench/delete_10k_2k_200MB     722 ±33%     563 ± 1%   ~     (p=0.700 n=3+3)
fsbench/write_sync_10MB        30.4 ± 3%    27.1 ± 1%   ~     (p=0.100 n=3+3)
```