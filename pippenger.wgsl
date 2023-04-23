const POINTS_PER_INVOCATION = 8u;
const PARTITION_SIZE = 6u;
const POW_PART = (1u << PARTITION_SIZE);
const NUM_PARTITIONS = POINTS_PER_INVOCATION / PARTITION_SIZE;
const PS_SZ = POW_PART;
const BB_SIZE = 256;
const BB_SIZE_FAKE = 20;

fn pippenger(points: array<JacobianPoint, POINTS_PER_INVOCATION>, scalars: array<ScalarField, POINTS_PER_INVOCATION>) -> JacobianPoint {

    // first calculate power set sums for each partition of points
    // then calculate the sets for each point
    var powerset_sums: array<JacobianPoint, PS_SZ>;

    var cur_sum: array<JacobianPoint, BB_SIZE>;

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
                powerset_sums[j] = jacobian_add(powerset_sums[mask], powerset_sums[u32(other_mask)]);
            }
        }

        for(var bb = BB_SIZE; bb >= 0; bb = bb - 1){
            var b = u32(bb);
            
            var powerset_idx = 0u;
            let modbW = b % W;
            let quotbW = b / W;
            for(var j = 0u; j < PARTITION_SIZE; j = j + 1){
                if((scalars[i * PARTITION_SIZE + j].limbs[quotbW] & (1u << modbW)) > 0) {
                    powerset_idx = powerset_idx | (1u << j);
                }
            }
            cur_sum[bb] = jacobian_add(cur_sum[bb], powerset_sums[powerset_idx]);
        }
    }
    var running_total: JacobianPoint;
    for(var bb = BB_SIZE_FAKE; bb >= 0; bb = bb - 1){
        running_total = jacobian_add(jacobian_double(running_total), cur_sum[bb]);
    }
    return running_total;
}
