fn pippenger_fake(points: array<u32, POINTS_PER_INVOCATION>, scalars: array<u32, POINTS_PER_INVOCATION>) -> u32 {

    // first calculate power set sums for each partition of points
    // then calculate the sets for each point
    var powerset_sums: array<u32, PS_SZ>;
    for(var i = 0u; i < NUM_PARTITIONS; i = i + 1){
        // compute all power sums in this partition
        var idx = 0u;
        let offset = i * POW_PART;
        for(var j = 1u; j < POW_PART; j = j + 1){
            if((i32(j) & -i32(j)) == i32(j)) {
                powerset_sums[offset + j] = points[i * PARTITION_SIZE + idx];
                idx = idx + 1;
            } else {
                let cur_point = points[i * PARTITION_SIZE + idx];
                let mask = j & u32(j - 1);
                let other_mask = j ^ mask;
                powerset_sums[offset + j] = powerset_sums[offset + mask] + powerset_sums[offset + u32(other_mask)];
            }
        }
    }
    var running_total = 0u;
    for(var bb = 20; bb >= 0; bb = bb - 1){
        var b = u32(bb);
        var cur_sum = 0u;
        for(var i = 0u; i < NUM_PARTITIONS; i = i + 1){
            var powerset_idx = 0u;
            for(var j = 0u; j < PARTITION_SIZE; j = j + 1){
                if((scalars[i * PARTITION_SIZE + j] & (1u << b)) > 0){
                    powerset_idx = powerset_idx | (1u << j);
                }
            }
            let offset = i * POW_PART;
            cur_sum = cur_sum + powerset_sums[offset + powerset_idx];
        }
        running_total = running_total * 2 + cur_sum;
    }
    return running_total;
}
