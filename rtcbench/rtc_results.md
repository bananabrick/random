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


1. Preventing wide compactions(5x fileszie overlap)
- `rtc_off` vs `prevent_wide`
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

2.
- `rtc_off` vs `level_change`
- Killing the compaction if it has already happened is killing most
  of the gains.
```
name                old ops/sec  new ops/sec  delta
ycsb/E/values=1024   43.0k ±12%   42.5k ±13%    ~     (p=1.000 n=5+5)
ycsb/A/values=1024   98.1k ± 1%   98.1k ± 3%    ~     (p=0.510 n=8+5)
ycsb/D/values=1024    140k ±13%    136k ±12%    ~     (p=0.548 n=5+5)
ycsb/F/values=1024   60.7k ± 1%   60.4k ± 2%    ~     (p=0.841 n=5+5)
ycsb/C/values=1024    393k ± 9%    385k ±10%    ~     (p=0.690 n=5+5)
ycsb/B/values=1024    271k ± 7%    265k ± 9%    ~     (p=0.690 n=5+5)

name                old read     new read     delta
ycsb/E/values=1024   54.9G ± 5%   54.3G ± 6%    ~     (p=0.690 n=5+5)
ycsb/A/values=1024    195G ± 1%    196G ± 2%    ~     (p=0.423 n=8+5)
ycsb/D/values=1024   96.5G ± 8%   95.7G ± 8%    ~     (p=0.841 n=5+5)
ycsb/F/values=1024    148G ± 2%    148G ± 2%    ~     (p=1.000 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   42.8G ± 4%  +3.73%  (p=0.016 n=5+5)
ycsb/B/values=1024   94.9G ± 4%   93.6G ± 5%    ~     (p=0.690 n=5+5)

name                old write    new write    delta
ycsb/E/values=1024   57.6G ± 5%   57.0G ± 6%    ~     (p=0.548 n=5+5)
ycsb/A/values=1024    230G ± 1%    231G ± 2%    ~     (p=0.423 n=8+5)
ycsb/D/values=1024    105G ± 9%    104G ± 8%    ~     (p=0.690 n=5+5)
ycsb/F/values=1024    226G ± 1%    226G ± 2%    ~     (p=1.000 n=5+5)
ycsb/C/values=1024   41.3G ± 1%   42.8G ± 4%  +3.73%  (p=0.016 n=5+5)
ycsb/B/values=1024    105G ± 5%    104G ± 6%    ~     (p=0.690 n=5+5)

name                old r-amp    new r-amp    delta
ycsb/E/values=1024    17.1 ± 9%    17.1 ±11%    ~     (p=1.000 n=5+5)
ycsb/A/values=1024    13.5 ± 3%    13.1 ± 7%    ~     (p=0.151 n=8+5)
ycsb/D/values=1024    10.2 ± 6%    10.3 ± 6%    ~     (p=1.000 n=5+5)
ycsb/F/values=1024    0.00         0.00         ~     (all equal)
ycsb/C/values=1024    5.20 ± 2%    5.26 ± 3%    ~     (p=0.460 n=5+5)
ycsb/B/values=1024    7.53 ± 1%    7.55 ± 3%    ~     (p=0.683 n=5+5)

name                old w-amp    new w-amp    delta
ycsb/E/values=1024    41.3 ± 8%    41.3 ± 8%    ~     (p=0.841 n=5+5)
ycsb/A/values=1024    7.19 ± 1%    7.21 ± 0%    ~     (p=0.581 n=8+5)
ycsb/D/values=1024    23.3 ± 5%    23.6 ± 3%    ~     (p=1.000 n=5+5)
ycsb/F/values=1024    5.72 ± 1%    5.74 ± 1%    ~     (p=0.190 n=5+5)
ycsb/C/values=1024    0.00         0.00         ~     (all equal)
ycsb/B/values=1024    11.9 ± 3%    12.1 ± 5%    ~     (p=0.841 n=5+5)
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
- Skipping compaction if level ratio is < 0.5
- 0.5 is obviously too high.
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
