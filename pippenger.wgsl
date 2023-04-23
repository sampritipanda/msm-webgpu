const POINTS_PER_INVOCATION = 8u;
const PARTITION_SIZE = 6u;
const POW_PART = (1u << PARTITION_SIZE);
const NUM_PARTITIONS = POINTS_PER_INVOCATION / PARTITION_SIZE;
const PS_SZ = POW_PART * NUM_PARTITIONS;

fn pippenger(points: array<JacobianPoint, POINTS_PER_INVOCATION>, scalars: array<ScalarField, POINTS_PER_INVOCATION>) -> JacobianPoint {

    // first calculate power set sums for each partition of points
    // then calculate the sets for each point

    var powerset_sums: array<JacobianPoint, PS_SZ>;
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
                powerset_sums[offset + j] = jacobian_add(powerset_sums[offset + mask], powerset_sums[offset + u32(other_mask)]);
            }
        }
    }
    var running_total: JacobianPoint = JacobianPoint(ZERO, ZERO, ONE);
    for(var bb = 255; bb >= 0; bb = bb - 1){
        var b = u32(bb);
        var cur_sum: JacobianPoint = JacobianPoint(ZERO, ZERO, ONE);
        for(var i = 0u; i < NUM_PARTITIONS; i = i + 1){
            var powerset_idx = 0u;
            let modbW = b % W;
            let quotbW = b / W;
            for(var j = 0u; j < PARTITION_SIZE; j = j + 1){
                if((scalars[i * PARTITION_SIZE + j].limbs[quotbW] & (1u << modbW)) > 0) {
                    powerset_idx = powerset_idx | (1u << j);
                }
            }
            let offset = i * POW_PART;
            cur_sum = jacobian_add(cur_sum, powerset_sums[offset + powerset_idx]);
        }
        running_total = jacobian_add(jacobian_double(running_total), cur_sum);
    }
    return running_total;
}
