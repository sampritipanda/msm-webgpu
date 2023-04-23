const WORKGROUP_SIZE = 64;
const NUM_INVOCATIONS = 256;
const MSM_SIZE = WORKGROUP_SIZE * NUM_INVOCATIONS;

@group(0) @binding(0)
var<storage, read_write> points: array<JacobianPoint>;
@group(0) @binding(1)
var<storage, read_write> scalars: array<ScalarField>;
@group(0) @binding(2)
var<storage, read_write> result: array<JacobianPoint, NUM_INVOCATIONS>;
@group(0) @binding(3)
var<storage, read_write> mem: array<JacobianPoint, MSM_SIZE>;

// 3 -> 2
// storage -> workgroup
// second stage


@compute @workgroup_size(WORKGROUP_SIZE)
fn main(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(local_invocation_id) local_id: vec3<u32>
) {
    let gidx = global_id.x;
    let lidx = local_id.x;

    mem[gidx] = jacobian_mul(points[gidx], scalars[gidx]);

    storageBarrier();

    for (var offset: u32 = WORKGROUP_SIZE / 2u; offset > 0u; offset = offset / 2u) {
        if (lidx < offset) {
            mem[gidx] = jacobian_add(mem[gidx], mem[gidx + offset]);
        }
        storageBarrier();
    }

    if (lidx == 0) {
        result[gidx/WORKGROUP_SIZE] = mem[gidx];
    }
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
