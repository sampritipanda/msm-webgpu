const WORKGROUP_SIZE = 128;

@group(0) @binding(0)
var<storage, read_write> points: array<JacobianPoint>;
@group(0) @binding(1)
var<storage, read_write> scalars: array<ScalarField>;
@group(0) @binding(2)
var<storage, read_write> result: JacobianPoint;
@group(0) @binding(3)
var<storage, read_write> spinlock: atomic<u32>;

var<workgroup> mem: array<JacobianPoint, WORKGROUP_SIZE>;

@compute @workgroup_size(WORKGROUP_SIZE)
fn main(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(local_invocation_id) local_id: vec3<u32>
) {
    let gidx = global_id.x;
    let lidx = local_id.x;

    result = jacobian_mul(points[0], scalars[0]);

    mem[lidx] = jacobian_mul(points[gidx], scalars[gidx]);

    workgroupBarrier();

    for (var offset: u32 = WORKGROUP_SIZE / 2u; offset > 0u; offset = offset / 2u) {
        if (lidx < offset) {
            mem[lidx] = jacobian_add(mem[lidx], mem[lidx + offset]);
        }
        workgroupBarrier();
    }

    // TODO: read about memory ordering and fix this when we have multiple global invocations
    if (lidx == 0) {
        var a: u32 = 0;
        // waiting for lock
        while (!atomicCompareExchangeWeak(&spinlock, 0, 1).exchanged) {
            a = a + 1u;
        }
        // got lock
        result = jacobian_add(result, mem[0]);
        // release lock
        atomicCompareExchangeWeak(&spinlock, 1, 0);
    }
}

