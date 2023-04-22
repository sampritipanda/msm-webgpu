@group(0) @binding(0)
var<storage, read_write> points: array<JacobianPoint>;
@group(0) @binding(1)
var<storage, read_write> scalars: array<ScalarField>;
@group(0) @binding(2)
var<storage, read_write> result: JacobianPoint;

const WORKGROUP_SIZE = 1;

// var<workgroup> mem: array<JacobianPoint, WORKGROUP_SIZE>;

@compute @workgroup_size(WORKGROUP_SIZE)
fn main(
    @builtin(global_invocation_id) global_id: vec3<u32>,
    @builtin(local_invocation_id) local_id: vec3<u32>
) {
    let gidx = global_id.x;
    let lidx = local_id.x;

    result = jacobian_double(points[gidx]);

    // workgroupBarrier();

    // for (var offset: u32 = WORKGROUP_SIZE / 2u; offset > 0u; offset = offset / 2u) {
    //     if (lidx < offset) {
    //         mem[lidx] = jacobian_add(mem[lidx], mem[lidx + offset]);
    //     }
    //     workgroupBarrier();
    // }

    // // TODO: read about memory ordering and fix this when we have multiple global invocations
    // if (lidx == 0) {
    //     result = mem[0];
    // }
}
