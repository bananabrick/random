- rtc result record
- `rtc_base` is the base read triggered compaction executable with no fixes.
- `rtc_off` is an executable with read triggered compaction turned off.
- `rtc_off` vs `rtc_base`
```
name                old ops/sec  new ops/sec  delta
ycsb/E/values=1024   43.0k ±12%   42.9k ±14%     ~     (p=1.000 n=5+5)
ycsb/A/values=1024   98.1k ± 1%   98.8k ± 2%     ~     (p=0.157 n=8+5)
ycsb/D/values=1024    140k ±13%    137k ±14%     ~     (p=0.841 n=5+5)
ycsb/F/values=1024   60.7k ± 1%   60.4k ± 3%     ~     (p=0.548 n=5+5)
ycsb/C/values=1024    393k ± 9%    594k ±13%  +51.19%  (p=0.008 n=5+5)
ycsb/B/values=1024    271k ± 7%    277k ±11%     ~     (p=0.841 n=5+5)

name                old read     new read     delta
ycsb/E/values=1024   54.9G ± 5%   54.0G ± 7%     ~     (p=0.548 n=5+5)
ycsb/A/values=1024    195G ± 1%    196G ± 0%   +0.67%  (p=0.044 n=8+5)
ycsb/D/values=1024   96.5G ± 8%   96.0G ± 8%     ~     (p=1.000 n=5+5)
ycsb/F/values=1024    148G ± 2%    149G ± 1%     ~     (p=0.548 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   57.5G ± 3%  +39.25%  (p=0.008 n=5+5)
ycsb/B/values=1024   94.9G ± 4%  101.4G ± 6%     ~     (p=0.222 n=5+5)

name                old write    new write    delta
ycsb/E/values=1024   57.6G ± 5%   56.7G ± 7%     ~     (p=0.690 n=5+5)
ycsb/A/values=1024    230G ± 1%    231G ± 1%   +0.71%  (p=0.030 n=8+5)
ycsb/D/values=1024    105G ± 9%    105G ± 9%     ~     (p=1.000 n=5+5)
ycsb/F/values=1024    226G ± 1%    227G ± 2%     ~     (p=0.841 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   57.5G ± 3%  +39.26%  (p=0.008 n=5+5)
ycsb/B/values=1024    105G ± 5%    112G ± 6%     ~     (p=0.222 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/E/values=1024    17.1 ± 9%    16.7 ±13%     ~     (p=0.690 n=5+5)
ycsb/A/values=1024    13.5 ± 3%    12.8 ± 5%   -5.33%  (p=0.009 n=8+5)
ycsb/D/values=1024    10.2 ± 6%    10.2 ± 8%     ~     (p=1.000 n=5+5)
ycsb/F/values=1024    0.00         0.00          ~     (all equal)
ycsb/C/values=1024    5.20 ± 2%    3.37 ±15%  -35.19%  (p=0.008 n=5+5)
ycsb/B/values=1024    7.53 ± 1%    7.12 ± 5%   -5.44%  (p=0.016 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/E/values=1024    41.3 ± 8%    40.9 ± 9%     ~     (p=0.841 n=5+5)
ycsb/A/values=1024    7.19 ± 1%    7.17 ± 1%     ~     (p=0.514 n=8+5)
ycsb/D/values=1024    23.3 ± 5%    23.7 ± 6%     ~     (p=0.548 n=5+5)
ycsb/F/values=1024    5.72 ± 1%    5.76 ± 1%     ~     (p=0.095 n=5+5)
ycsb/C/values=1024    0.00         0.00          ~     (all equal)
ycsb/B/values=1024    11.9 ± 3%    12.5 ± 5%     ~     (p=0.095 n=5+5)
```


1. Preventing wide compactions
- `rtc_off` vs `prevent_wide`

- 5x filesize overlap
```
name                old ops/sec  new ops/sec  delta
ycsb/E/values=1024   43.0k ±12%   43.3k ±10%     ~     (p=1.000 n=5+5)
ycsb/A/values=1024   98.1k ± 1%   98.2k ± 2%     ~     (p=0.510 n=8+5)
ycsb/D/values=1024    140k ±13%    138k ±11%     ~     (p=0.841 n=5+5)
ycsb/C/values=1024    393k ± 9%    497k ± 9%  +26.51%  (p=0.008 n=5+5)
ycsb/B/values=1024    271k ± 7%    271k ±11%     ~     (p=1.000 n=5+5)

name                old read     new read     delta
ycsb/E/values=1024   54.9G ± 5%   55.2G ± 6%     ~     (p=1.000 n=5+5)
ycsb/A/values=1024    195G ± 1%    196G ± 2%     ~     (p=0.496 n=8+5)
ycsb/D/values=1024   96.5G ± 8%   96.2G ± 7%     ~     (p=1.000 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   52.9G ± 7%  +28.16%  (p=0.008 n=5+5)
ycsb/B/values=1024   94.9G ± 4%   97.3G ± 7%     ~     (p=0.310 n=5+5)

name                old write    new write    delta
ycsb/E/values=1024   57.6G ± 5%   58.0G ± 6%     ~     (p=1.000 n=5+5)
ycsb/A/values=1024    230G ± 1%    230G ± 2%     ~     (p=0.496 n=8+5)
ycsb/D/values=1024    105G ± 9%    105G ± 7%     ~     (p=0.841 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   52.9G ± 7%  +28.17%  (p=0.008 n=5+5)
ycsb/B/values=1024    105G ± 5%    108G ± 7%     ~     (p=0.310 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/E/values=1024    17.1 ± 9%    16.5 ± 7%     ~     (p=0.421 n=5+5)
ycsb/A/values=1024    13.5 ± 3%    12.9 ± 2%   -4.58%  (p=0.009 n=8+5)
ycsb/D/values=1024    10.2 ± 6%    10.1 ± 6%     ~     (p=0.421 n=5+5)
ycsb/C/values=1024    5.20 ± 2%    4.57 ±15%  -12.19%  (p=0.008 n=5+5)
ycsb/B/values=1024    7.53 ± 1%    7.15 ± 4%   -5.12%  (p=0.008 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/E/values=1024    41.3 ± 8%    41.3 ± 7%     ~     (p=0.841 n=5+5)
ycsb/A/values=1024    7.19 ± 1%    7.20 ± 1%     ~     (p=0.614 n=8+5)
ycsb/D/values=1024    23.3 ± 5%    23.5 ± 5%     ~     (p=1.000 n=5+5)
ycsb/C/values=1024    0.00         0.00          ~     (all equal)
ycsb/B/values=1024    11.9 ± 3%    12.2 ± 6%     ~     (p=0.246 n=5+5)
```

- 10x filesize overlap
```
rtc_off vs the fix
name                old ops/sec  new ops/sec  delta
ycsb/A/values=1024   79.4k ± 4%   79.4k ± 1%     ~     (p=0.548 n=5+5)
ycsb/D/values=1024   87.8k ±16%   84.6k ± 8%     ~     (p=0.310 n=5+5)
ycsb/F/values=1024   62.9k ± 1%   63.0k ± 1%     ~     (p=1.000 n=5+5)
ycsb/C/values=1024    297k ±15%    344k ± 5%  +15.63%  (p=0.016 n=5+5)
ycsb/B/values=1024    199k ±14%    199k ± 4%     ~     (p=0.421 n=5+5)

name                old read     new read     delta
ycsb/A/values=1024   96.2G ± 1%   96.0G ± 1%     ~     (p=0.690 n=5+5)
ycsb/D/values=1024   52.2G ± 1%   51.5G ± 3%     ~     (p=0.556 n=4+5)
ycsb/F/values=1024   75.8G ± 2%   75.8G ± 0%     ~     (p=0.690 n=5+5)
ycsb/C/values=1024   41.5G ± 6%   55.9G ± 3%  +34.84%  (p=0.008 n=5+5)
ycsb/B/values=1024   58.9G ± 4%   61.8G ± 2%   +4.82%  (p=0.032 n=5+5)

name                old write    new write    delta
ycsb/A/values=1024    111G ± 2%    111G ± 1%     ~     (p=0.421 n=5+5)
ycsb/D/values=1024   55.1G ± 2%   54.2G ± 3%     ~     (p=0.413 n=4+5)
ycsb/F/values=1024    116G ± 1%    116G ± 0%     ~     (p=1.000 n=5+5)
ycsb/C/values=1024   41.4G ± 6%   55.9G ± 3%  +34.84%  (p=0.008 n=5+5)
ycsb/B/values=1024   63.1G ± 4%   65.9G ± 2%   +4.45%  (p=0.032 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/A/values=1024    21.5 ± 9%    22.1 ± 9%     ~     (p=0.841 n=5+5)
ycsb/D/values=1024    17.8 ±14%    18.7 ± 8%     ~     (p=0.310 n=5+5)
ycsb/F/values=1024    0.00         0.00          ~     (all equal)
ycsb/C/values=1024    7.13 ± 9%    6.23 ± 4%  -12.60%  (p=0.008 n=5+5)
ycsb/B/values=1024    10.4 ±10%    10.6 ± 1%     ~     (p=0.151 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/A/values=1024    8.54 ± 3%    8.57 ± 1%     ~     (p=0.460 n=5+5)
ycsb/D/values=1024    37.6 ± 6%    39.5 ± 6%     ~     (p=0.222 n=5+5)
ycsb/F/values=1024    5.67 ± 2%    5.67 ± 1%     ~     (p=1.000 n=5+5)
ycsb/C/values=1024    0.00         0.00          ~     (all equal)
ycsb/B/values=1024    19.5 ±11%    20.4 ± 3%     ~     (p=0.151 n=5+5)

- Since the benchmark numbers were lower than the initial comparison of
  rtc_off vs rtc_base, we re-run rtc_base, and compare it with our fix.

arjunnair@Arjuns-MacBook-Pro rtc_wide % benchstat stat_base stat_wide
name                old ops/sec  new ops/sec  delta
ycsb/A/values=1024   79.7k ± 2%   79.4k ± 1%   ~     (p=0.690 n=5+5)
ycsb/D/values=1024   88.2k ± 7%   84.6k ± 8%   ~     (p=0.421 n=5+5)
ycsb/F/values=1024   63.1k ± 1%   63.0k ± 1%   ~     (p=1.000 n=5+5)
ycsb/C/values=1024    358k ±11%    344k ± 5%   ~     (p=0.222 n=5+5)
ycsb/B/values=1024    204k ± 7%    199k ± 4%   ~     (p=0.548 n=5+5)

name                old read     new read     delta
ycsb/A/values=1024   96.3G ± 1%   96.0G ± 1%   ~     (p=0.690 n=5+5)
ycsb/D/values=1024   51.4G ± 4%   51.5G ± 3%   ~     (p=1.000 n=5+5)
ycsb/F/values=1024   75.8G ± 1%   75.8G ± 0%   ~     (p=1.000 n=5+5)
ycsb/C/values=1024   54.6G ± 4%   55.9G ± 3%   ~     (p=0.222 n=5+5)
ycsb/B/values=1024   61.6G ± 4%   61.8G ± 2%   ~     (p=0.841 n=5+5)

name                old write    new write    delta
ycsb/A/values=1024    111G ± 1%    111G ± 1%   ~     (p=0.690 n=5+5)
ycsb/D/values=1024   54.2G ± 4%   54.2G ± 3%   ~     (p=1.000 n=5+5)
ycsb/F/values=1024    116G ± 1%    116G ± 0%   ~     (p=1.000 n=5+5)
ycsb/C/values=1024   54.6G ± 4%   55.9G ± 3%   ~     (p=0.222 n=5+5)
ycsb/B/values=1024   65.8G ± 4%   65.9G ± 2%   ~     (p=0.841 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/A/values=1024    21.8 ± 6%    22.1 ± 9%   ~     (p=1.000 n=5+5)
ycsb/D/values=1024    18.0 ± 7%    18.7 ± 8%   ~     (p=0.341 n=5+5)
ycsb/F/values=1024    0.00         0.00        ~     (all equal)
ycsb/C/values=1024    5.96 ±10%    6.23 ± 4%   ~     (p=0.310 n=5+5)
ycsb/B/values=1024    10.3 ± 4%    10.6 ± 1%   ~     (p=0.341 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/A/values=1024    8.57 ± 3%    8.57 ± 1%   ~     (p=0.690 n=5+5)
ycsb/D/values=1024    37.8 ± 6%    39.5 ± 6%   ~     (p=0.548 n=5+5)
ycsb/F/values=1024    5.66 ± 0%    5.67 ± 1%   ~     (p=0.889 n=5+5)
ycsb/C/values=1024    0.00         0.00        ~     (all equal)
ycsb/B/values=1024    19.8 ± 7%    20.4 ± 3%   ~     (p=0.548 n=5+5)
```

3.
- `rtc_off` vs `limit_queue`
- Using a linkedlist/queue size of 5.
- This is killing perf, might be due to small queue size, or perhaps
  due to a linked list.
```
name                old ops/sec  new ops/sec  delta
ycsb/E/values=1024   43.0k ±12%   41.8k ±11%    ~     (p=0.690 n=5+5)
ycsb/A/values=1024   98.1k ± 1%   97.8k ± 2%    ~     (p=0.679 n=8+5)
ycsb/D/values=1024    140k ±13%    135k ±12%    ~     (p=0.690 n=5+5)
ycsb/F/values=1024   60.7k ± 1%   60.2k ± 2%    ~     (p=0.548 n=5+5)
ycsb/C/values=1024    393k ± 9%    390k ±10%    ~     (p=1.000 n=5+5)
ycsb/B/values=1024    271k ± 7%    268k ±12%    ~     (p=0.690 n=5+5)

name                old read     new read     delta
ycsb/E/values=1024   54.9G ± 5%   54.7G ± 6%    ~     (p=1.000 n=5+5)
ycsb/A/values=1024    195G ± 1%    196G ± 1%    ~     (p=0.348 n=8+5)
ycsb/D/values=1024   96.5G ± 8%   95.7G ± 7%    ~     (p=1.000 n=5+5)
ycsb/F/values=1024    148G ± 2%    148G ± 2%    ~     (p=1.000 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   43.8G ± 3%  +6.13%  (p=0.008 n=5+5)
ycsb/B/values=1024   94.9G ± 4%  100.8G ± 6%    ~     (p=0.222 n=5+5)

name                old write    new write    delta
ycsb/E/values=1024   57.6G ± 5%   57.3G ± 6%    ~     (p=0.841 n=5+5)
ycsb/A/values=1024    230G ± 1%    231G ± 1%    ~     (p=0.483 n=8+5)
ycsb/D/values=1024    105G ± 9%    104G ± 7%    ~     (p=0.841 n=5+5)
ycsb/F/values=1024    226G ± 1%    225G ± 2%    ~     (p=0.690 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   43.8G ± 3%  +6.14%  (p=0.008 n=5+5)
ycsb/B/values=1024    105G ± 5%    111G ± 7%    ~     (p=0.222 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/E/values=1024    17.1 ± 9%    17.4 ± 6%    ~     (p=0.548 n=5+5)
ycsb/A/values=1024    13.5 ± 3%    13.2 ± 2%    ~     (p=0.082 n=8+5)
ycsb/D/values=1024    10.2 ± 6%    10.3 ± 4%    ~     (p=0.690 n=5+5)
ycsb/F/values=1024    0.00         0.00         ~     (all equal)
ycsb/C/values=1024    5.20 ± 2%    5.23 ± 3%    ~     (p=0.968 n=5+5)
ycsb/B/values=1024    7.53 ± 1%    7.32 ± 4%  -2.89%  (p=0.048 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/E/values=1024    41.3 ± 8%    42.3 ± 6%    ~     (p=0.421 n=5+5)
ycsb/A/values=1024    7.19 ± 1%    7.24 ± 1%    ~     (p=0.413 n=8+5)
ycsb/D/values=1024    23.3 ± 5%    23.7 ± 4%    ~     (p=0.310 n=5+5)
ycsb/F/values=1024    5.72 ± 1%    5.75 ± 1%    ~     (p=0.230 n=5+5)
ycsb/C/values=1024    0.00         0.00         ~     (all equal)
ycsb/B/values=1024    11.9 ± 3%    12.8 ± 5%  +6.92%  (p=0.016 n=5+5)
```

4.
- `rtc_off` vs `fix_ratio`
- Skipping compaction if level score is less than some number.

- 0.5
```
name                old ops/sec  new ops/sec  delta
ycsb/E/values=1024   43.0k ±12%   42.7k ±12%    ~     (p=1.000 n=5+5)
ycsb/A/values=1024   98.1k ± 1%   98.1k ± 3%    ~     (p=0.710 n=8+5)
ycsb/D/values=1024    140k ±13%    138k ±11%    ~     (p=0.690 n=5+5)
ycsb/F/values=1024   60.7k ± 1%   60.6k ± 2%    ~     (p=0.841 n=5+5)
ycsb/C/values=1024    393k ± 9%    392k ± 9%    ~     (p=0.841 n=5+5)
ycsb/B/values=1024    271k ± 7%    273k ± 9%    ~     (p=0.841 n=5+5)

name                old read     new read     delta
ycsb/E/values=1024   54.9G ± 5%   55.0G ± 6%    ~     (p=1.000 n=5+5)
ycsb/A/values=1024    195G ± 1%    196G ± 2%    ~     (p=0.623 n=8+5)
ycsb/D/values=1024   96.5G ± 8%   96.1G ± 6%    ~     (p=1.000 n=5+5)
ycsb/F/values=1024    148G ± 2%    148G ± 1%    ~     (p=0.690 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   42.8G ± 3%  +3.70%  (p=0.032 n=5+5)
ycsb/B/values=1024   94.9G ± 4%   99.4G ± 5%    ~     (p=0.222 n=5+5)

name                old write    new write    delta
ycsb/E/values=1024   57.6G ± 5%   57.7G ± 6%    ~     (p=1.000 n=5+5)
ycsb/A/values=1024    230G ± 1%    231G ± 2%    ~     (p=0.623 n=8+5)
ycsb/D/values=1024    105G ± 9%    105G ± 7%    ~     (p=1.000 n=5+5)
ycsb/F/values=1024    226G ± 1%    226G ± 2%    ~     (p=0.690 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   42.8G ± 3%  +3.70%  (p=0.032 n=5+5)
ycsb/B/values=1024    105G ± 5%    110G ± 5%    ~     (p=0.222 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/E/values=1024    17.1 ± 9%    16.9 ± 8%    ~     (p=0.841 n=5+5)
ycsb/A/values=1024    13.5 ± 3%    12.9 ± 4%    ~     (p=0.082 n=8+5)
ycsb/D/values=1024    10.2 ± 6%    10.2 ± 6%    ~     (p=1.000 n=5+5)
ycsb/F/values=1024    0.00         0.00         ~     (all equal)
ycsb/C/values=1024    5.20 ± 2%    5.20 ± 2%    ~     (p=0.881 n=5+5)
ycsb/B/values=1024    7.53 ± 1%    7.16 ± 4%  -4.96%  (p=0.016 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/E/values=1024    41.3 ± 8%    41.7 ± 9%    ~     (p=0.841 n=5+5)
ycsb/A/values=1024    7.19 ± 1%    7.22 ± 1%    ~     (p=0.648 n=8+5)
ycsb/D/values=1024    23.3 ± 5%    23.4 ± 4%    ~     (p=0.548 n=5+5)
ycsb/F/values=1024    5.72 ± 1%    5.72 ± 1%    ~     (p=1.000 n=5+5)
ycsb/C/values=1024    0.00         0.00         ~     (all equal)
ycsb/B/values=1024    11.9 ± 3%    12.4 ± 5%  +3.92%  (p=0.032 n=5+5)
```

- 0.25.
```
name                old ops/sec  new ops/sec  delta
ycsb/A/values=1024   78.9k ± 2%   79.0k ± 5%   ~     (p=0.310 n=5+5)
ycsb/D/values=1024   82.4k ±17%   85.4k ±15%   ~     (p=0.841 n=5+5)
ycsb/F/values=1024   63.2k ± 1%   62.8k ± 1%   ~     (p=0.310 n=5+5)
ycsb/C/values=1024    289k ±14%    295k ±15%   ~     (p=0.690 n=5+5)
ycsb/B/values=1024    193k ±13%    200k ±17%   ~     (p=0.690 n=5+5)

name                old read     new read     delta
ycsb/A/values=1024   96.7G ± 1%   96.2G ± 1%   ~     (p=0.548 n=5+5)
ycsb/D/values=1024   49.8G ± 8%   50.2G ± 6%   ~     (p=1.000 n=5+5)
ycsb/F/values=1024   75.4G ± 1%   75.3G ± 1%   ~     (p=0.690 n=5+5)
ycsb/C/values=1024   42.4G ± 3%   41.9G ± 7%   ~     (p=0.310 n=5+5)
ycsb/B/values=1024   59.4G ± 4%   60.6G ± 4%   ~     (p=0.310 n=5+5)

name                old write    new write    delta
ycsb/A/values=1024    111G ± 1%    111G ± 2%   ~     (p=0.690 n=5+5)
ycsb/D/values=1024   52.4G ± 8%   52.9G ± 7%   ~     (p=0.841 n=5+5)
ycsb/F/values=1024    116G ± 1%    116G ± 0%   ~     (p=0.548 n=5+5)
ycsb/C/values=1024   42.3G ± 3%   41.9G ± 7%   ~     (p=0.310 n=5+5)
ycsb/B/values=1024   63.3G ± 5%   64.8G ± 4%   ~     (p=0.421 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/A/values=1024    21.1 ± 4%    21.1 ± 9%   ~     (p=0.548 n=5+5)
ycsb/D/values=1024    18.8 ±12%    18.2 ±11%   ~     (p=0.889 n=5+5)
ycsb/F/values=1024    0.00         0.00        ~     (all equal)
ycsb/C/values=1024    7.36 ± 8%    7.25 ± 9%   ~     (p=0.881 n=5+5)
ycsb/B/values=1024    10.8 ± 7%    10.2 ±12%   ~     (p=0.222 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/A/values=1024    8.68 ± 1%    8.63 ± 3%   ~     (p=0.460 n=5+5)
ycsb/D/values=1024    39.5 ±11%    38.3 ±10%   ~     (p=0.690 n=5+5)
ycsb/F/values=1024    5.63 ± 1%    5.65 ± 1%   ~     (p=0.460 n=5+5)
ycsb/C/values=1024    0.00         0.00        ~     (all equal)
ycsb/B/values=1024    20.3 ±10%    20.1 ±17%   ~     (p=1.000 n=5+5)
```
