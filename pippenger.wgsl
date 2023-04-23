const POINTS_PER_INVOCATION = 64u;
const PARTITION_SIZE = 8u;
const POW_PART = (1u << PARTITION_SIZE);
const NUM_PARTITIONS = POINTS_PER_INVOCATION / PARTITION_SIZE;
const PS_SZ = POW_PART;
const BB_SIZE = 256;
const BB_SIZE_FAKE = 20;

@group(0) @binding(4)
var<storage, read_write> powerset_sums: array<JacobianPoint, PS_SZ * NUM_INVOCATIONS>;
@group(0) @binding(5)
var<storage, read_write> cur_sum: array<JacobianPoint, BB_SIZE * NUM_INVOCATIONS>;

fn pippenger(gidx: u32) -> JacobianPoint {
    var ps_base = gidx * PS_SZ;
    var sum_base = i32(gidx) * BB_SIZE;
    var point_base = gidx * POINTS_PER_INVOCATION;

    // first calculate power set sums for each partition of points
    // then calculate the sets for each point

    for(var bb = 0; bb < BB_SIZE; bb = bb + 1) {
        cur_sum[sum_base + bb] = JacobianPoint(ZERO, ZERO, ONE);
    }
    for(var i = 0u; i < PS_SZ; i = i + 1) {
        powerset_sums[ps_base + i] = JacobianPoint(ZERO, ZERO, ONE);
    }


    for(var i = 0u; i < NUM_PARTITIONS; i = i + 1) {

        // compute all power sums in this partition
        var idx = 0u;
        for(var j = 1u; j < POW_PART; j = j + 1){
            if((i32(j) & -i32(j)) == i32(j)) {
                powerset_sums[ps_base + j] = points[point_base + i * PARTITION_SIZE + idx];
                idx = idx + 1;
            } else {
                let cur_point = points[point_base + i * PARTITION_SIZE + idx];
                let mask = j & u32(j - 1);
                let other_mask = j ^ mask;
                powerset_sums[ps_base + j] = jacobian_add(powerset_sums[ps_base + mask], powerset_sums[ps_base + u32(other_mask)]);
            }
        }

        for(var bb: i32 = BB_SIZE - 1; bb >= 0; bb = bb - 1){
            var b = u32(bb);
            
            var powerset_idx = 0u;
            let modbW = b % W;
            let quotbW = b / W;
            for(var j = 0u; j < PARTITION_SIZE; j = j + 1){
                if((scalars[point_base + i * PARTITION_SIZE + j].limbs[quotbW] & (1u << modbW)) > 0) {
                    powerset_idx = powerset_idx | (1u << j);
                }
            }
            cur_sum[sum_base + bb] = jacobian_add(cur_sum[sum_base + bb], powerset_sums[ps_base + powerset_idx]);
        }
    }
    var running_total: JacobianPoint;
    for(var bb = BB_SIZE - 1; bb >= 0; bb = bb - 1){
        running_total = jacobian_add(jacobian_double(running_total), cur_sum[sum_base + bb]);
    }
    return running_total;
}
