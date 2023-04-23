fn pippenger_fake(points: array<u32, POINTS_PER_INVOCATION>, scalars: array<u32, POINTS_PER_INVOCATION>) -> u32 {

    // first calculate power set sums for each partition of points
    // then calculate the sets for each point
    var powerset_sums: array<u32, PS_SZ>;

    var cur_sum: array<u32, BB_SIZE_FAKE>;

    for(var i = 0u; i < NUM_PARTITIONS; i = i + 1) {

        // compute all power sums in this partition
        var idx = 0u;
        for(var j = 1u; j < POW_PART; j = j + 1){
            if((i32(j) & -i32(j)) == i32(j)) {
                powerset_sums[j] = points[i * PARTITION_SIZE + idx];
                idx = idx + 1;
            } else {
                let cur_point = points[i * PARTITION_SIZE + idx];
                let mask = j & u32(j - 1);
                let other_mask = j ^ mask;
                powerset_sums[j] = powerset_sums[mask] + powerset_sums[u32(other_mask)];
            }
        }

        for(var bb = BB_SIZE_FAKE; bb >= 0; bb = bb - 1){
            var b = u32(bb);
            
            var powerset_idx = 0u;
            for(var j = 0u; j < PARTITION_SIZE; j = j + 1){
                if((scalars[i * PARTITION_SIZE + j] & (1u << b)) > 0){
                    powerset_idx = powerset_idx | (1u << j);
                }
            }
            cur_sum[bb] = cur_sum[bb] + powerset_sums[powerset_idx];
        }
    }
    var running_total = 0u;
    for(var bb = BB_SIZE_FAKE; bb >= 0; bb = bb - 1){
        running_total = running_total * 2u + cur_sum[bb];
    }
    return running_total;
}
