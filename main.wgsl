// 3 -> 2
// storage -> workgroup
// second stage


@compute @workgroup_size(1)
fn main(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(local_invocation_id) local_id: vec3<u32>
) {
    let gidx = global_id.x;
    let lidx = local_id.x;

    result[gidx] = pippenger(gidx);
}

@compute @workgroup_size(256)
fn aggregate(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(local_invocation_id) local_id: vec3<u32>
) {
    let gidx = global_id.x;
    let lidx = local_id.x;

    const split = NUM_INVOCATIONS / 256;

    for (var j = 1; j < split; j = j + 1) {
        result[lidx] = jacobian_add(result[lidx], result[lidx + split * 256]);
    }

    storageBarrier();

    for (var offset: u32 = 256 / 2u; offset > 0u; offset = offset / 2u) {
        if (lidx < offset) {
            result[gidx] = jacobian_add(result[gidx], result[gidx + offset]);
        }
        storageBarrier();
    }
}
